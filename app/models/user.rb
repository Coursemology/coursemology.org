class User < ActiveRecord::Base
  acts_as_voter

  #TODO
  # default_scope where(:is_pending_deletion => false)
  default_scope includes(:system_role)

  before_create :set_default_role
  before_create :set_default_profile_pic
  after_create  :auto_enroll_for_invited

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :display_name, :name, :profile_photo_url
  attr_accessible :provider, :uid
  attr_accessible :use_uploaded_picture
  attr_accessible :time_zone

  protected_attributes :system_role_id

  validates :name, presence: true
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.zones_map(&:name), if: :time_zone

  before_update :send_out_notification_email, :if => :email_changed?
  after_update :update_user_course, :if => :name_changed?

  has_many :user_courses, dependent: :destroy
  has_many :courses, through: :user_courses

  belongs_to :system_role, class_name: "Role"

  DEFAULT_PROFILE_PIC_URL = 'http://coursemology.s3.amazonaws.com/public/default_profile_pic.png'

  def is_admin?
    self.system_role && self.system_role.name == 'superuser'
  end

  def is_lecturer?
    self.is_admin? || (self.system_role && self.system_role.name == 'lecturer')
  end

  def can_publish_to_fb?(fb_access_token)
    graph = Koala::Facebook::API.new(fb_access_token)
    permissions = graph.get_connections("me", "permissions")
    # check for publish_actions, permissions is of class GraphCollection
    # which extends Array, so need to index it first to get the hash
    !permissions[0]["publish_actions"].nil?
  end

  def show_fb_achievement_share_button?(fb_access_token)
    can_publish_to_fb?(fb_access_token) || fb_publish_actions_request_count < 3
  end

  def self.admins
    User.where(system_role_id: Role.admin.first)
  end

  def self.lecturers
    User.where(system_role_id: Role.lecturer.first)
  end

  def self.normals
    User.where(system_role_id: Role.normal.first)
  end

  def update_external_account(auth)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first

    if user && user != self
      return false
    end

    self.provider = auth.provider
    self.uid = auth.uid
    if self.use_default_photo_pic?
      self.profile_photo_url = auth.info.image
    end
    self.save
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource = nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.find_by_email(auth.info.email)
      if user
        user.provider = auth.provider
        user.uid = auth.uid
        if user.use_default_photo_pic?
          user.profile_photo_url = auth.info.image
        end
      else
        user = User.create(name: auth.extra.raw_info.name,
                           provider: auth.provider,
                           uid: auth.uid,
                           email: auth.info.email,
                           password: Devise.friendly_token[0,20],
                           profile_photo_url: auth.info.image
        )
      end
      user.save
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.display_name = user.name = data["name"] if user.name.blank?
      end
    end
  end

  def use_default_photo_pic?
    self.profile_photo_url == DEFAULT_PROFILE_PIC_URL
  end

  def self.search(search, role = nil)
    search_condition = "%" + search.downcase + "%"
    result = User.where(['lower(users.name) LIKE ? OR lower(users.email) LIKE ?', search_condition, search_condition])
    if role
      result = result.where(system_role_id: role)
    end
    result
    #find(:all, :conditions => ['lower(name) LIKE ? OR lower(email) LIKE ?', search_condition, search_condition])
  end

  def get_role
    self.system_role.title
  end

  def get_profile_photo_url
    if !use_uploaded_picture? && self.uid && self.provider == "facebook"
      'http://graph.facebook.com/'+self.uid+'/picture'
    else
      self.profile_photo_url
    end

  end

  def send_out_notification_email
    UserMailer.delay.email_changed(name, email, email_was)
  end

  def auto_enroll_for_invited(confirm_token = nil)
    invs = MassEnrollmentEmail.where(email: self.email)
    if !invs.first and confirm_token
      invs = MassEnrollmentEmail.where(confirm_token: confirm_token)
    end

    invs.each do |inv|
      unless inv.signed_up?
        inv.course.enrol_user(self, Role.find_by_name("student"))
        inv.signed_up = true
        inv.save
      end
    end
  end

  def update_user_course
    self.user_courses.includes(:course).each do |uc|
      next unless uc.course.allow_name_change?

      uc.name = self.name
      uc.save
    end
  end

  def to_s
    self.name
  end

  def get_user_course(course)
    UserCourse.find_by_user_id_and_course_id(
        self.id,
        course.id
    )
  end

  def after_database_authentication
    #self.update_attribute(:invite_code, nil)
    self.is_logged_in = true
  end

  def update_user_role(role_id)
    self.system_role_id = role_id
    self.save
  end

  private
  def set_default_role
    unless self.system_role
      self.system_role = Role.find_by_name('normal')
    end
  end

  def set_default_profile_pic
    unless self.profile_photo_url
      self.profile_photo_url = DEFAULT_PROFILE_PIC_URL
    end
  end

end

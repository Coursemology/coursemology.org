class CommentsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:show, :index, :edit, :new, :view_for_question]

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_course = curr_user_course
    authorize! :read, @comment.commentable
    if @comment.save
      commentable = @comment.commentable

      # update / create comment_topic
      comment_topic = CommentTopic.where(
        topic_id: commentable.id,
        topic_type: commentable.class).first_or_create
      comment_topic.course = @course
      comment_topic.last_commented_at = @comment.created_at
      comment_topic.permalink = comment_topic.permalink || get_comment_permalink(commentable)
      comment_topic.pending = curr_user_course.is_student?
      comment_topic.save

      @comment.comment_topic = comment_topic
      @comment.save

      # commentable.last_commented_at = @comment.created_at
      # commentable.save

      CommentSubscription.populate_subscription(@comment)

      # commentable.set_pending_comments(curr_user_course.is_student?)

      if @course.email_notify_enabled? PreferableItem.new_comment
        commentable.notify_user(curr_user_course, @comment, comment_topic.permalink)
      end

      respond_to do |format|
        #format.html { redirect_to params[:origin] }
        format.json {render json: @comment.commentable.comments_json(curr_user_course)}
      end
    end
  end

  def index
    if can? :see, :pending_comments
      @tab = params[:_tab]

      @all_topics = @course.comment_topics
      @pending_comments = @course.get_pending_comments
      @my_topics = curr_user_course.comment_topics
      @mine_pending_comments = @my_topics.where(pending: true)

      case @tab
        when 'all'
          @topics = @all_topics
        when 'pending'
          @topics = @pending_comments
        when 'minepending'
          @topics = @mine_pending_comments
        when 'mine'
          @topics = @my_topics
        else
          @tab = 'pending'
          @topics = @pending_comments
      end
    else
      @topics = curr_user_course.comment_topics
    end

    @topics = sorting_and_paging(@topics)
  end

  def pending_toggle
    if !params[:cid] || !params[:ctype]
      return
    end
    pending_comment = PendingComments.find_by_answer_id_and_answer_type(params[:cid], params[:ctype])
    unless pending_comment
      pending_comment = PendingComments.create(answer_id:params[:cid], answer_type:params[:ctype],pending: false)
    end
    pending_comment.pending = !pending_comment.pending
    if pending_comment.save
      respond_to do |format|
        format.json {render json: {status: 'OK'}}
      end
    end
  end

  def destroy
    @comment = Comment.where(id: params[:id]).first
    if @comment
      comment_topic = @comment.comment_topic
      @comment.destroy
      # remove comment topic without comments
      if comment_topic.comments.count == 0
        comment_topic.destroy
      end
    end
    respond_to do |format|
      format.json {render json: {status: 'OK'}}
    end
  end

  def update
    @comment = Comment.where(id: params[:id]).first
    if @comment
      @comment.text = params[:text]
      @comment.save
    end
    respond_to do |format|
      format.json {render json: {c: ApplicationHelper::style_format(@comment.text, false), o: @comment.text }}
    end
  end

  def get_comments
    commentable = nil
    if params[:comment]
      commentable = Comment.where(params[:comment]).first.commentable
    end

    respond_to do |format|
      resp = commentable ? commentable.comments_json(curr_user_course, false) : {}
      puts resp
      format.json {render json:resp }
    end
  end

  def view_for_question
    qn_type = params[:qn_type] || ''
    qn_id = params[:qn_id].to_i || 0
    @question = nil
    case
      when qn_type == 'Mcq'
        @question = Mcq.find(qn_id)
      when qn_type == 'CodingQuestion'
        @question = CodingQuestion.find(qn_id)
    end

    if !@question
      redirect_to course_url(@course)
      return
    end

    # verify subscription exist
    cs = CommentSubscription.where(
        user_course_id: curr_user_course.id,
        topic_id: @question.id,
        topic_type: @question.class).count
    if cs == 0
      redirect_to access_denied_path
      return
    end

    @asm = @question.asm_qns.first.asm
    @current_question = @question
  end

  private
  def sorting_and_paging(topics)
    @comments_paging = @course.comments_paging_pref
    @topics = topics.sort_by { |ans| ans.last_commented_at }.reverse

    if @comments_paging.display?
      @topics = Kaminari.paginate_array(@topics).page(params[:page]).per(@comments_paging.prefer_value.to_i)
    end
    @topics
  end

  def get_comment_permalink(commentable)
    case commentable
    when Mcq, CodingQuestion
      return course_comments_question_url(@course, qn_type: commentable.class, qn_id: commentable.id)
    when StdAnswer, StdCodingAnswer
      sbm_answer = commentable.sbm_answers.first
      submission = sbm_answer ? sbm_answer.sbm : nil

      question = commentable.question
      asm_qn = question.asm_qns.first
      mission = asm_qn ? asm_qn.asm : nil

      if mission && submission
        return course_mission_submission_url(@course, mission, submission)
      end
    end
    return course_comments_url(@course)
  end
end

class CommentsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:show, :index, :edit, :new, :view_for_question]

  # TODO: the following are not necessary any more. to be removed once everything is verified to work.
  # 1. remove last_commented_at in other classes
  # 2. remove table pending_comments
  # 3. remove commentable_id, commentable_type in comment_subscriptions and comments
  #
  # TODO:
  # comment.js to take advantage of comment_topic (ex: in the get_comments function)

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_course = curr_user_course
    authorize! :read, @comment.commentable
    #if @comment.save
    commentable = @comment.commentable

    # update / create comment_topic
    comment_topic = CommentTopic.where(
        topic_id: commentable.id,
        topic_type: commentable.class).first_or_create
    comment_topic.course = @course
    comment_topic.last_commented_at = Time.now
    comment_topic.permalink = comment_topic.permalink || get_comment_permalink(commentable)
    comment_topic.pending = curr_user_course.is_student?
    comment_topic.save

    @comment.comment_topic = comment_topic
    @comment.save

    CommentSubscription.populate_subscription(@comment)

    if @course.email_notify_enabled? PreferableItem.new_comment and comment_topic.can_access?
      comment_topic.notify_user(curr_user_course, @comment, comment_topic.permalink)
    end

    respond_to do |format|
      format.json {render json: comment_topic.comments_json(curr_user_course)}
    end
    #end
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
          if @mine_pending_comments.count > 0
            @tab = 'minepending'
            @topics = @mine_pending_comments
          elsif @pending_comments.count > 0
            @tab = 'pending'
            @topics = @pending_comments
          elsif @my_topics.count > 0
            @tab = 'mine'
            @topics = @my_topics
          else
            @tab = 'all'
            @topics = @all_topics
          end
      end
    else
      topic_ids = curr_user_course.comment_topics.select{|t| t.can_access?}.map{ |t| t.id }
      @topics = curr_user_course.comment_topics.where(id: topic_ids)
    end

    @comments_paging = @course.comments_paging_pref
    if @comments_paging.display?
      @topics = @topics.page(params[:page]).per(@comments_paging.prefer_value.to_i)
    end
  end

  def pending_toggle
    if !params[:cid]
      return
    end
    comment_topic = @course.comment_topics.find(params[:cid])
    if comment_topic
      comment_topic.pending = !comment_topic.pending
      if comment_topic.save
        puts comment_topic.to_json
        respond_to do |format|
          format.json {render json: {status: 'OK'}}
        end
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
    comment_topic = nil
    if params[:comment]
      comment_topic = CommentTopic.where(params[:comment]).first
    end

    respond_to do |format|
      resp = CommentTopic.comments_to_json(comment_topic, curr_user_course, false)
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
    @comment_topic = @course.comment_topics.where(
        topic_id: @question.id,
        topic_type: @question.class).first

    cs = @comment_topic ? @comment_topic.comment_subscriptions.where(user_course_id: curr_user_course.id).count : 0

    if !@comment_topic || cs == 0
      redirect_to access_denied_path
      return
    end

    @asm = @question.asm_qns.first.asm
    @current_question = @question
  end

  private

  def get_comment_permalink(commentable)
    case commentable
      when Assessment::Question, Assessment::CodingQuestion, Assessment::McqQuestion, Assessment::GeneralQuestion
        return course_comments_question_url(@course, qn_type: commentable.class, qn_id: commentable.id)
      when Assessment::Answer, Assessment::CodingAnswer, Assessment::McqAnswer, Assessment::TextAnswer
        submission = commentable.submission
        assessment = submission.assessment

        return course_assessment_submission_url(assessment.course, assessment, submission)
    end
    course_comments_url(@course)
  end
end

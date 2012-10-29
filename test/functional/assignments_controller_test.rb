require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  setup do
    @assignment = assignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assignment" do
    assert_difference('Assignment.count') do
      post :create, assignment: { attempt_limit: @assignment.attempt_limit, auto_graded: @assignment.auto_graded, class_id: @assignment.class_id, close_at: @assignment.close_at, creator_id: @assignment.creator_id, deadline: @assignment.deadline, description: @assignment.description, exp: @assignment.exp, open_at: @assignment.open_at, order: @assignment.order, timelimit: @assignment.timelimit }
    end

    assert_redirected_to assignment_path(assigns(:assignment))
  end

  test "should show assignment" do
    get :show, id: @assignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @assignment
    assert_response :success
  end

  test "should update assignment" do
    put :update, id: @assignment, assignment: { attempt_limit: @assignment.attempt_limit, auto_graded: @assignment.auto_graded, class_id: @assignment.class_id, close_at: @assignment.close_at, creator_id: @assignment.creator_id, deadline: @assignment.deadline, description: @assignment.description, exp: @assignment.exp, open_at: @assignment.open_at, order: @assignment.order, timelimit: @assignment.timelimit }
    assert_redirected_to assignment_path(assigns(:assignment))
  end

  test "should destroy assignment" do
    assert_difference('Assignment.count', -1) do
      delete :destroy, id: @assignment
    end

    assert_redirected_to assignments_path
  end
end

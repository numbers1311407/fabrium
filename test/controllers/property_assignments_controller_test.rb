require 'test_helper'

class PropertyAssignmentsControllerTest < ActionController::TestCase
  setup do
    @property_assignment = property_assignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:property_assignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create property_assignment" do
    assert_difference('PropertyAssignment.count') do
      post :create, property_assignment: {  }
    end

    assert_redirected_to property_assignment_path(assigns(:property_assignment))
  end

  test "should show property_assignment" do
    get :show, id: @property_assignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @property_assignment
    assert_response :success
  end

  test "should update property_assignment" do
    patch :update, id: @property_assignment, property_assignment: {  }
    assert_redirected_to property_assignment_path(assigns(:property_assignment))
  end

  test "should destroy property_assignment" do
    assert_difference('PropertyAssignment.count', -1) do
      delete :destroy, id: @property_assignment
    end

    assert_redirected_to property_assignments_path
  end
end

require 'test_helper'

class FabricVariantsControllerTest < ActionController::TestCase
  setup do
    @fabric_variant = fabric_variants(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fabric_variants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fabric_variant" do
    assert_difference('FabricVariant.count') do
      post :create, fabric_variant: {  }
    end

    assert_redirected_to fabric_variant_path(assigns(:fabric_variant))
  end

  test "should show fabric_variant" do
    get :show, id: @fabric_variant
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fabric_variant
    assert_response :success
  end

  test "should update fabric_variant" do
    patch :update, id: @fabric_variant, fabric_variant: {  }
    assert_redirected_to fabric_variant_path(assigns(:fabric_variant))
  end

  test "should destroy fabric_variant" do
    assert_difference('FabricVariant.count', -1) do
      delete :destroy, id: @fabric_variant
    end

    assert_redirected_to fabric_variants_path
  end
end

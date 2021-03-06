require 'test_helper'

class BallotsControllerTest < ActionController::TestCase
  setup do
    @ballot = ballots(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ballots)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ballot" do
    assert_difference('Ballot.count') do
      post :create, ballot: { author_id: @ballot.author_id, content_id: @ballot.content_id, member_id: @ballot.member_id, myballots_id: @ballot.myballots_id, myballots_type: @ballot.myballots_type, outcome: @ballot.outcome, over: @ballot.over, vote_type: @ballot.vote_type }
    end

    assert_redirected_to ballot_path(assigns(:ballot))
  end

  test "should show ballot" do
    get :show, id: @ballot
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ballot
    assert_response :success
  end

  test "should update ballot" do
    put :update, id: @ballot, ballot: { author_id: @ballot.author_id, content_id: @ballot.content_id, member_id: @ballot.member_id, myballots_id: @ballot.myballots_id, myballots_type: @ballot.myballots_type, outcome: @ballot.outcome, over: @ballot.over, vote_type: @ballot.vote_type }
    assert_redirected_to ballot_path(assigns(:ballot))
  end

  test "should destroy ballot" do
    assert_difference('Ballot.count', -1) do
      delete :destroy, id: @ballot
    end

    assert_redirected_to ballots_path
  end
end

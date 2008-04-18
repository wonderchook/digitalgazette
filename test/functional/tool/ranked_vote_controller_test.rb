require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/ranked_vote_controller'

# Re-raise errors caught by the controller.
class Tool::RankedVoteController; def rescue_action(e) raise e end; end

class Tool::RankedVoteControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :polls, :possibles

  def setup
    @controller = Tool::RankedVoteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login_as :orange
    get :create, :id => Tool::RankedVote.class_display_name
  end

  def test_create_show_add_and_show
    assert_no_difference 'Page.count' do
      get :create, :id => Tool::RankedVote.class_display_name
      assert_template 'tool/base/create'
    end
  
    assert_difference 'Tool::RankedVote.count' do
      post :create, :id => Tool::RankedVote.class_display_name, :page => {:title => 'test title'}
      assert_response :redirect
    end
    
    p = Page.find(:all)[-1] # most recently created page (?)
    get :show, :page_id => p.id
    assert_response :redirect
    assert_redirected_to @controller.page_url(assigns(:page), :action => 'edit') # redirect to edit since no possibles
    
    assert_difference 'p.data.possibles.count' do
      post :add_possible, :page_id => p.id, :possible => {:name => "new option", :description => ""}
    end

    get :show, :page_id => p.id
    assert_response :success
    assert_template 'tool/ranked_vote/show'
  end
  
  # TODO: tests for sort, update_possible, edit_possible, destroy_possible,
end
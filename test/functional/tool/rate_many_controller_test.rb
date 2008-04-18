require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/rate_many_controller'

# Re-raise errors caught by the controller.
class Tool::RateManyController; def rescue_action(e) raise e end; end

class Tool::RateManyControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :polls, :possibles

  def setup
    @controller = Tool::RateManyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_all

    login_as :orange

    assert_no_difference 'Page.count' do
      get :create, :id => Tool::RateMany.class_display_name
      assert_template 'tool/base/create'
    end
  
    assert_difference 'Tool::RateMany.count' do
      post :create, :id => Tool::RateMany.class_display_name, :page => {:title => 'test title'}
      assert_response :redirect
    end
    
    p = Page.find(:all)[-1] # most recently created page (?)
    get :show, :page_id => p.id
    assert_response :success
    assert_template 'tool/rate_many/show'
    
    assert_difference 'p.data.possibles.count' do
      post :add_possible, :page_id => p.id, :possible => {:name => "new option", :description => ""}
    end
    assert_not_nil assigns(:possible)

    assert_difference 'p.data.possibles.count', -1 do
      post :destroy_possible, :page_id => p.id, :possible => assigns(:possible).id

    end
    
    post :add_possible, :page_id => p.id, :possible => {:name => "new option", :description => ""}
    id = assigns(:possible).id
    post :vote_one, :page_id => p.id, :id => id, :value => "2"
    assert_equal 2, Poll::Possible.find(id).votes.find(:all).find { |p| p.user = users(:orange) }.value
  end
  
  # TODO: tests for vote, clear votes, sort
end
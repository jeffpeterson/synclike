class UsersController < ApplicationController
  def new
  end
  
  def edit
    @user = User.find params[:id]
  end
  
  def show
    @user = current_user
    render 'new' unless @user
  end
  
  def update_feed
    FeedEntry.update_feed_for current_user if current_user
    redirect_to root_path, success: "Feeds updated!"
  end
  
  def update_feeds
    FeedEntry.update_feeds
    redirect_to root_path, success: "Feeds updated!"
  end
  
  def update
    redirect_to root_path and return unless current_user
    if current_user.update_attributes params[:user]
      redirect_to root_path, success: "Settings updated!"
    else
      render 'edit'
    end
  end
  
  def create
    @user = User.new params[:user]
    if @user.save
      redirect_to "/auth/rdio"
    else
      render 'new'
    end
  end
end

class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def edit
    @user = User.find params[:id]
  end
  
  def show
    @user = User.find params[:id]
  end
  
  def sync_feed
    @user = User.find params[:id]
    FeedEntry.update_feed_for @user
    
    redirect_to user_path(@user), success: "Pandora feed synced."
  end
  
  def create
    @user = User.new params[:user]
    if @user.save
      redirect_to @user, success: "You are now registered!"
    else
      render 'new'
    end
  end
end

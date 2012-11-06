class UsersController < ApplicationController
  def new
  end
  
  def edit
    @user = current_user
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
    @user = current_user
    redirect_to root_path and return unless @user

    if @user.update_attributes params[:user]
      flash[:success] = "settings updated!"
      redirect_to root_path 
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

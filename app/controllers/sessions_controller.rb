class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_by_auth_hash auth_hash
    session[:user_id] = @user.id
    redirect_to root_url, success: "Signed in!"
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, success: "Signed out!"
  end
  
  def failure
    redirect_to root_url, error: "Authentication failed! Try again."
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
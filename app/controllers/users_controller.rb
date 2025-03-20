class UsersController < ApplicationController
  # Set @user for actions that depend on the username parameter.
  before_action :set_user, only: %i[ show liked feed discover ]
  
  # Restrict access to feed and discover pages so that only the profile owner can view them.
  before_action :must_be_owner_to_view, only: %i[ feed discover ]

  # GET /users
  def index
    # Assuming @q is defined (for example via Ransack) to perform search queries.
    @users = @q.result(distinct: true)
  end

  # GET /:username
  def show
    # Public profile view. In the view, you can conditionally display sections 
    # based on privacy settings (e.g. only showing posts if the profile is public or if the current user is allowed).
  end

  # GET /:username/liked
  def liked
    # Display posts that @user has liked. This page is public.
  end

  # GET /:username/feed
  def feed
    # This action is restricted to the profile owner by the before_action.
    # Load the feed items for @user here.
  end

  # GET /:username/discover
  def discover
    # This action is restricted to the profile owner by the before_action.
    # Load discover items for @user here.
  end

  private

    # Finds the user based on the :username parameter, or falls back to the current_user.
    def set_user
      if params[:username]
        @user = User.find_by!(username: params.fetch(:username))
      else
        @user = current_user
      end
    end

    # Ensures that only the owner can view feed and discover pages.
    def must_be_owner_to_view
      unless current_user == @user
        redirect_back fallback_location: root_url, alert: "You're not authorized for that."
      end
    end
end

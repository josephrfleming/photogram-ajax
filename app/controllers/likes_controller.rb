class LikesController < ApplicationController
  before_action :authorize_create, only: [:create]
  before_action :set_like, only: [:destroy]
  before_action :authorize_destroy, only: [:destroy]

  # POST /likes
  def create
    @like = Like.new(like_params)
    @like.fan = current_user  # Ensure the like is always by the logged-in user

    if @like.save
      redirect_back fallback_location: @like.photo, notice: "Like was successfully created."
    else
      redirect_back fallback_location: root_url, alert: "Unable to create like."
    end
  end

  # DELETE /likes/1
  def destroy
    @like.destroy
    redirect_back fallback_location: @like.photo, notice: "Like was successfully destroyed."
  end

  private

    def set_like
      @like = Like.find(params[:id])
    end

    def like_params
      # We remove :fan_id from the strong parameters so it can't be overridden.
      params.require(:like).permit(:photo_id)
    end

    # Only allow a user to like a photo if:
    #  - They are the owner, OR
    #  - The photo's owner is public, OR
    #  - They are following the photo's owner
    def authorize_create
      photo = Photo.find(params[:like][:photo_id])

      if current_user != photo.owner && photo.owner.private? && !current_user.leaders.include?(photo.owner)
        redirect_back fallback_location: root_url, alert: "Not authorized to like this photo."
      end
    end

    # Only allow the fan (or possibly the photo owner) to remove the like.
    # This example allows only the fan to destroy their own like.
    def authorize_destroy
      unless current_user == @like.fan
        redirect_back fallback_location: root_url, alert: "Not authorized to remove this like."
      end
    end
end

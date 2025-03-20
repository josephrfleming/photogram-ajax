class FollowRequestsController < ApplicationController
  before_action :set_follow_request, only: %i[ show edit update destroy ]
  before_action :ensure_authorized, only: [:update, :destroy]

  # GET /follow_requests
  def index
    # Show only pending follow requests where the current user is the recipient.
    @follow_requests = FollowRequest.where(recipient: current_user)
  end

  # GET /follow_requests/1
  def show
    # Optionally, restrict viewing to the sender or recipient.
    unless current_user == @follow_request.sender || current_user == @follow_request.recipient
      redirect_back fallback_location: root_url, alert: "Not authorized."
    end
  end

  # GET /follow_requests/new
  def new
    @follow_request = FollowRequest.new
  end

  # GET /follow_requests/1/edit
  def edit
    # Only the sender should be able to edit a follow request (for example, to cancel it).
    unless current_user == @follow_request.sender
      redirect_back fallback_location: root_url, alert: "Not authorized."
    end
  end

  # POST /follow_requests
  def create
    @follow_request = FollowRequest.new(follow_request_params)
    @follow_request.sender = current_user

    respond_to do |format|
      if @follow_request.save
        format.html { redirect_back fallback_location: root_url, notice: "Follow request was successfully created." }
        format.json { render :show, status: :created, location: @follow_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @follow_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /follow_requests/1
  def update
    respond_to do |format|
      if @follow_request.update(follow_request_params)
        format.html { redirect_back fallback_location: root_url, notice: "Follow request was successfully updated." }
        format.json { render :show, status: :ok, location: @follow_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @follow_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /follow_requests/1
  def destroy
    @follow_request.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Follow request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_follow_request
      @follow_request = FollowRequest.find(params[:id])
    end

    # Only allow trusted parameters.
    # Note: We remove :sender_id since the sender is always current_user.
    def follow_request_params
      params.require(:follow_request).permit(:recipient_id, :status)
    end

    # Ensure that only authorized users can update or destroy a follow request.
    # For update (accept/reject), only the recipient is allowed.
    # For destroy, either the sender (cancelling) or the recipient (rejecting) is allowed.
    def ensure_authorized
      if action_name == "update"
        unless current_user == @follow_request.recipient
          redirect_back fallback_location: root_url, alert: "Not authorized."
        end
      elsif action_name == "destroy"
        unless current_user == @follow_request.sender || current_user == @follow_request.recipient
          redirect_back fallback_location: root_url, alert: "Not authorized."
        end
      end
    end
end

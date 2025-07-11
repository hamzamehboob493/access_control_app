class InvitationsController < ApplicationController
  before_action :set_invitation_user, only: [ :show, :accept ]
  before_action :set_organization_membership, only: [ :show, :accept ]

  def show
    if @user.nil? || !@user.invitation_pending?
      redirect_to root_path, alert: "Invalid or expired invitation."
      return
    end

    # Ensure the user has a valid invitation token
    if @user.invitation_token.blank?
      Rails.logger.error "User #{@user.id} found but has no invitation token"
      redirect_to root_path, alert: "Invalid invitation link."
      return
    end

    if current_user
      # User is already logged in
      if @user != current_user
        redirect_to root_path, alert: "This invitation is for a different user."
        return
      end

      # User is logged in and invitation is for them
      if @user.profile_completed?
        # Profile already completed, just accept membership
        redirect_to accept_invitation_path(params[:token]), method: :post
        return
      end
    end

    @organization = @membership&.organization
    # Don't override @user - it was already set by the before_action and has the invitation_token
  end

  def accept
    if @user.nil? || !@user.invitation_pending?
      redirect_to root_path, alert: "Invalid or expired invitation."
      return
    end

    # Ensure the user has a valid invitation token
    if @user.invitation_token.blank?
      Rails.logger.error "User #{@user.id} found but has no invitation token in accept action"
      redirect_to root_path, alert: "Invalid invitation link."
      return
    end

    if request.post?
      # Process the invitation acceptance with user details
      begin
        user_params = invitation_params

        # Accept the invitation and complete profile
        @user.accept_invitation!(user_params)

        # Update organization membership
        if @membership
          @membership.update!(
            status: "active",
            joined_at: Time.current,
            approved_at: Time.current,
            approved_by: @membership.invited_by
          )
        end

        # Log the user in
        session[:user_id] = @user.id

        redirect_to @membership ? @membership.organization : root_path,
                    notice: "Welcome! You've successfully joined #{@membership&.organization&.name || 'the organization'}."
      rescue ActiveRecord::RecordInvalid => e
        @organization = @membership&.organization
        @user.errors.add(:base, e.message) unless @user.errors.any?
        render :show
      end
    else
      # Show the acceptance form
      @organization = @membership&.organization
    end
  end

  private

  def set_invitation_user
    @user = User.find_by(invitation_token: params[:token])
  end

  def set_organization_membership
    @membership = OrganizationMembership.find_by(invitation_token: params[:token]) if @user
  end

  def invitation_params
    params.require(:user).permit(:first_name, :last_name, :date_of_birth, :phone_number, :password, :password_confirmation)
  end
end

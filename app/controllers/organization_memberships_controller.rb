class OrganizationMembershipsController < ApplicationController
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_membership, only: [ :show, :update, :destroy, :approve, :reject, :suspend, :reactivate, :re_invite ]

  def index
    authorize @organization, :manage_members?
    @memberships = @organization.organization_memberships
                                .includes(:user, :approved_by, :invited_by)
                                .order(:created_at)

    # Filter by status if provided
    @memberships = @memberships.where(status: params[:status]) if params[:status].present?

    # Paginate results
    @memberships = @memberships.page(params[:page]).per(20)

    @pending_count = @organization.organization_memberships.pending.count
    @active_count = @organization.organization_memberships.active.count
  end

  def show
    authorize @membership, :show?
  end

  def new
    authorize @organization, :invite_members?
    @membership = @organization.organization_memberships.build
  end

  def create
    # Handle different types of membership creation
    if params[:invitation_token].present?
      # Accepting an invitation
      handle_invitation_acceptance
    elsif params[:invite_email].present?
      # Creating an invitation
      handle_invitation_creation
    else
      # Direct membership request
      handle_membership_request
    end
  end

  def invite
    authorize @organization, :invite_members?

    email = params[:email]&.strip&.downcase
    role = params[:role] || "member"

    if email.blank?
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Email address is required for invitations."
      return
    end

    begin
      # Create or find user and set up invitation
      user = User.invite!(email, current_user)

      # Check if user already has a membership in this organization
      existing_membership = @organization.organization_memberships.find_by(user: user)
      if existing_membership && %w[active pending].include?(existing_membership.status)
        status_text = existing_membership.status == "active" ? "already a member" : "has a pending invitation"
        redirect_to organization_organization_memberships_path(@organization),
                    alert: "User #{status_text} of this organization."
        return
      end

      # Create invitation membership
      invitation = @organization.organization_memberships.build(
        user: user,
        role: role,
        status: "pending",
        invited_by: current_user,
        verification_method: "invitation",
        invited_email: email,
        invitation_token: user.invitation_token  # Ensure token is synced
      )

      # Generate invitation token (using user's token)
      invitation.invitation_token = user.invitation_token

      if invitation.save
        # Update last invited timestamp
        invitation.update!(last_invited_at: Time.current)

        # Send invitation email
        send_invitation_email(invitation, email)

        redirect_to organization_organization_memberships_path(@organization),
                    notice: "Invitation sent successfully to #{email}."
      else
        # Show specific validation errors
        error_messages = invitation.errors.full_messages.join(", ")
        Rails.logger.error "Invitation save failed: #{error_messages}"

        redirect_to organization_organization_memberships_path(@organization),
                    alert: "Failed to create invitation: #{error_messages}"
      end
    rescue => e
      Rails.logger.error "Invitation failed: #{e.message}"
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Failed to send invitation: #{e.message}"
    end
  end

  def update
    authorize @membership, :update?

    if @membership.update(membership_params)
      redirect_to organization_organization_membership_path(@organization, @membership),
                  notice: "Membership updated successfully."
    else
      render :show
    end
  end

  def destroy
    authorize @membership, :destroy?

    if @membership.destroy
      redirect_to organization_organization_memberships_path(@organization),
                  notice: "Membership removed successfully."
    else
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Failed to remove membership."
    end
  end

  def approve
    authorize @membership, :approve?

    begin
      @membership.approve!(current_user, params[:notes])
      redirect_to organization_organization_memberships_path(@organization),
                  notice: "#{@membership.user.first_name}'s membership has been approved."
    rescue => e
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Failed to approve membership: #{e.message}"
    end
  end

  def reject
    authorize @membership, :reject?

    begin
      @membership.reject!(current_user, params[:notes])
      redirect_to organization_organization_memberships_path(@organization),
                  notice: "#{@membership.user.first_name}'s membership has been rejected."
    rescue => e
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Failed to reject membership: #{e.message}"
    end
  end

  def suspend
    authorize @membership, :suspend?

    begin
      @membership.suspend!(current_user, params[:notes])
      redirect_to organization_organization_memberships_path(@organization),
                  notice: "#{@membership.user.first_name}'s membership has been suspended."
    rescue => e
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Failed to suspend membership: #{e.message}"
    end
  end

  def reactivate
    authorize @membership, :reactivate?

    begin
      @membership.reactivate!(current_user, params[:notes])
      redirect_to organization_organization_memberships_path(@organization),
                  notice: "#{@membership.user.first_name}'s membership has been reactivated."
    rescue => e
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Failed to reactivate membership: #{e.message}"
    end
  end

  def re_invite
    authorize @membership, :re_invite?

    # Check if re-invite is appropriate
    unless can_re_invite?(@membership)
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "This member cannot be re-invited at this time."
      return
    end

    begin
      # Generate new invitation token
      if @membership.user
        # User exists but profile incomplete - update their invitation token
        new_token = SecureRandom.urlsafe_base64(32)
        @membership.user.update!(
          invitation_token: new_token,
          profile_completed: false
        )
        @membership.update!(invitation_token: new_token)
      else
        # No user exists yet - create new user
        email = @membership.invited_email
        user = User.invite!(email, current_user)
        @membership.update!(
          user: user,
          invitation_token: user.invitation_token
        )
      end

      # Send new invitation email
      send_invitation_email(@membership, @membership.invited_email)

      # Update last invited timestamp
      @membership.update!(last_invited_at: Time.current)

      redirect_to organization_organization_memberships_path(@organization),
                  notice: "Invitation resent successfully to #{@membership.invited_email}."
    rescue => e
      Rails.logger.error "Re-invite failed: #{e.message}"
      redirect_to organization_organization_memberships_path(@organization),
                  alert: "Failed to resend invitation: #{e.message}"
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_membership
    @membership = @organization.organization_memberships.find(params[:id])
  end

  def handle_invitation_acceptance
    token = params[:invitation_token]
    membership = @organization.organization_memberships.find_by(invitation_token: token)

    if membership && membership.pending?
      membership.update!(
        user: current_user,
        status: "active",
        joined_at: Time.current,
        verification_method: "invitation"
      )

      redirect_to @organization, notice: "Welcome to the organization!"
    else
      redirect_to @organization, alert: "Invalid or expired invitation."
    end
  end

  def handle_invitation_creation
    email = params[:invite_email].strip.downcase
    role = params[:role] || "member"

    # Similar logic to invite action
    redirect_to invite_organization_organization_memberships_path(@organization, email: email, role: role)
  end

  def handle_membership_request
    @membership = @organization.organization_memberships.build(membership_params)
    @membership.user = current_user
    @membership.requested_at = Time.current
    @membership.verification_method = "direct_approval"

    if @membership.save
      # Notify organization admins
      notify_organization_admins(@membership)

      redirect_to @organization, notice: "Membership request sent successfully. You will be notified when it is reviewed."
    else
      redirect_to @organization, alert: "Failed to send membership request."
    end
  end

  def send_invitation_email(membership, email)
    # Generate the invitation URL using the user's invitation token
    invitation_token = membership.user&.invitation_token || membership.invitation_token
    invitation_url = invitation_url(invitation_token)

    begin
      # Send the invitation email
      OrganizationMailer.invitation_email(membership, email, invitation_url).deliver_now

      Rails.logger.info "Invitation email sent successfully to #{email} for #{@organization.name}"
    rescue => e
      Rails.logger.error "Failed to send invitation email to #{email}: #{e.message}"
      # Note: We don't fail the invitation creation if email fails - the user can still use the invitation token
    end

    # Log invitation details for debugging
    Rails.logger.info "INVITATION CREATED:"
    Rails.logger.info "To: #{email}"
    Rails.logger.info "Organization: #{@organization.name}"
    Rails.logger.info "Role: #{membership.role}"
    Rails.logger.info "Invited by: #{current_user.first_name} #{current_user.last_name}"
    Rails.logger.info "Invitation URL: #{invitation_url}"
    Rails.logger.info "Token: #{invitation_token}"
  end

  def notify_organization_admins(membership)
    # This would typically send emails to organization admins
    # For now, we'll just log it
    Rails.logger.info "New membership request from #{membership.user.email} for #{membership.organization.name}"
  end

  def membership_params
    params.require(:organization_membership).permit(:role, :verification_notes)
  end

  def can_re_invite?(membership)
    # Can re-invite if:
    # 1. Status is pending
    # 2. User exists but profile is not completed
    # 3. No user exists yet (invitation never accepted)

    return false unless membership.status == "pending"

    if membership.user
      # User exists - can re-invite if profile not completed
      !membership.user.profile_completed?
    else
      # No user exists - can always re-invite
      true
    end
  end
end

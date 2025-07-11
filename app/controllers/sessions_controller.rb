class SessionsController < ApplicationController
  def new
    # Clear any existing flash messages when showing login form
    flash.clear if request.get?
    redirect_to root_path, notice: "Already signed in ..." if current_user.present?
  end

  def create
    # Parameter validation
    email = params[:email]&.strip&.downcase
    password = params[:password]

    # Basic validation
    if email.blank? || password.blank?
      flash.now[:alert] = "Please enter both email and password."
      render :new, status: :unprocessable_entity
      return
    end

    # Find user and authenticate
    user = User.find_by(email: email)

    if user.nil?
      # User not found - generic error message for security
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
      return
    end

    unless user.authenticate(password)
      # Wrong password - generic error message for security
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
      return
    end

    # Authentication successful - handle different user scenarios
    begin
      # Set user session
      session[:user_id] = user.id

      # Handle invitation acceptance if present
      if params[:invitation_token].present?
        # Find user by invitation token
        invited_user = User.find_by(invitation_token: params[:invitation_token])

        if invited_user && invited_user.invitation_pending?
          # Check if this is the correct user for the invitation
          if invited_user == user
            # User is logging in with correct account - redirect to complete profile
            redirect_to invitation_path(params[:invitation_token]),
                        notice: "Please complete your profile to accept the invitation."
            return
          else
            redirect_to root_path, alert: "This invitation is for a different email address."
            return
          end
        else
          # Invalid or expired invitation
          redirect_to root_path, alert: "Invalid or expired invitation."
          return
        end
      end

      # Check for age-based restrictions
      if user.minor? && user.requires_parental_consent? && !user.parental_consent_valid?
        redirect_to new_parental_consent_path,
          alert: "Account access requires parental consent. Please complete the consent process."
        return
      end

      # Successful login
      redirect_to root_path, notice: "Welcome back, #{user.first_name}!"

    rescue => e
      # Log error for debugging (in production, you'd use a proper logger)
      Rails.logger.error "Login error for user #{user.id}: #{e.message}"

      # Clear session in case of error
      session[:user_id] = nil

      flash.now[:alert] = "An error occurred during login. Please try again."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    user_name = current_user&.first_name
    session[:user_id] = nil
    session.clear # Clear entire session for security

    if user_name
      redirect_to login_path, notice: "Goodbye, #{user_name}!"
    else
      redirect_to login_path, notice: "You have been logged out."
    end
  end
end

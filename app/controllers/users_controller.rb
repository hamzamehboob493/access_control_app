class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update ]
  before_action :ensure_current_user, only: [ :show, :edit, :update ]

  def new
    @user = User.new
  end

  def create
    # Validate required parameters
    unless user_params_valid?
      flash.now[:alert] = "Please fill in all required fields."
      @user = User.new(user_params)
      render :new, status: :unprocessable_entity
      return
    end

    @user = User.new(user_params)

    begin
      if @user.save
        # Set user session
        session[:user_id] = @user.id
        Rails.logger.info "User created successfully: #{@user.email}"

        # Handle age-based registration flow
        if @user.minor?
          if @user.requires_parental_consent?
            # Redirect to parental consent setup for minors
            redirect_to new_parental_consent_path,
              notice: "Account created! As a minor, you need parental consent to access all features."
          else
            # Minor but no parental consent required
            redirect_to root_path,
              success: "Account created successfully! Welcome to Access Control App."
          end
        else
          # Adult user - full access
          redirect_to root_path,
            success: "Account created successfully! Welcome to Access Control App."
        end
      else
        # Registration failed - show specific errors
        Rails.logger.warn "User registration failed: #{@user.errors.full_messages.join(', ')}"

        # Set appropriate flash message based on error type
        if @user.errors[:email].any?
          flash.now[:alert] = "Please check your email address and try again."
        elsif @user.errors[:password].any?
          flash.now[:alert] = "Please check your password requirements and try again."
        elsif @user.errors[:phone_number].any?
          flash.now[:alert] = "Please enter a valid US phone number."
        elsif @user.errors[:date_of_birth].any?
          flash.now[:alert] = "Please enter a valid date of birth."
        else
          flash.now[:alert] = "Please correct the errors below and try again."
        end

        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.error "Database constraint violation during user creation: #{e.message}"
      @user = User.new(user_params)
      @user.errors.add(:email, "is already taken") if e.message.include?("email")
      @user.errors.add(:phone_number, "is already taken") if e.message.include?("phone")
      flash.now[:alert] = "An account with this information already exists."
      render :new, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Unexpected error during user creation: #{e.message}"
      flash.now[:alert] = "An unexpected error occurred. Please try again."
      @user = User.new(user_params)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # User is already loaded and authorized by before_action
  end

  def edit
    # User is already loaded and authorized by before_action
  end

  def update
    # User is already loaded and authorized by before_action

    begin
      if @user.update(user_params)
        Rails.logger.info "User updated successfully: #{@user.email}"
        redirect_to @user, success: "Profile updated successfully!"
      else
        Rails.logger.warn "User update failed: #{@user.errors.full_messages.join(', ')}"

        # Set appropriate flash message based on error type
        if @user.errors[:email].any?
          flash.now[:alert] = "Please check your email address and try again."
        elsif @user.errors[:password].any?
          flash.now[:alert] = "Please check your password requirements and try again."
        elsif @user.errors[:phone_number].any?
          flash.now[:alert] = "Please enter a valid US phone number."
        else
          flash.now[:alert] = "Please correct the errors below and try again."
        end

        render :edit, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.error "Database constraint violation during user update: #{e.message}"
      @user.errors.add(:email, "is already taken") if e.message.include?("email")
      @user.errors.add(:phone_number, "is already taken") if e.message.include?("phone")
      flash.now[:alert] = "This information is already in use by another account."
      render :edit, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Unexpected error during user update: #{e.message}"
      flash.now[:alert] = "An unexpected error occurred. Please try again."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "User not found: #{params[:id]}"
      redirect_to root_path, alert: "User not found."
    end
  end

  def ensure_current_user
    return unless @user

    unless current_user == @user
      Rails.logger.warn "Unauthorized access attempt: User #{current_user&.id} tried to access User #{@user.id}"
      redirect_to root_path, alert: "Access denied."
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :date_of_birth, :password, :password_confirmation)
  end

  def user_params_valid?
    required_fields = [ :first_name, :last_name, :email, :phone_number, :date_of_birth, :password, :password_confirmation ]
    user_params_hash = user_params.to_h

    required_fields.all? { |field| user_params_hash[field].present? }
  end
end

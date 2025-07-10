class AgeVerificationController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @age_group = @user.age_group
    @requires_consent = @user.requires_parental_consent?
    @consent_status = @user.parental_consent_valid? if @requires_consent
  end

  def update
    @user = current_user

    if @user.update(user_params)
      if @user.requires_parental_consent? && !@user.parental_consent_valid?
        redirect_to parental_consent_path, notice: "Age updated. Parental consent required."
      else
        redirect_to profile_path, notice: "Age information updated successfully."
      end
    else
      render :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:date_of_birth)
  end
end

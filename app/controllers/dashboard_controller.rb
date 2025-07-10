class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @organizations = @user.organizations.limit(5)
    @age_restrictions = age_restrictions_for_user
  end

  private

  def age_restrictions_for_user
    restrictions = []
    restrictions << "Minor - requires supervision" if @user.minor?
    restrictions << "Cannot create organizations" if @user.minor?
    restrictions << "Age-appropriate content only" if @user.age < 13
    restrictions
  end
end

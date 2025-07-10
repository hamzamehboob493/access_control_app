class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [ :show, :edit, :update, :destroy, :analytics ]

  def index
    @organizations = policy_scope(Organization).includes(:organization_memberships)
    @organizations = @organizations.ransack(params[:q]).result if params[:q]
    @organizations = @organizations.page(params[:page])
  end

  def show
    authorize @organization
    @membership = current_user.organization_memberships.find_by(organization: @organization)
    @age_group_stats = @organization.analytics_data[:members_by_age_group] if policy(@organization).view_analytics?
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def create
    @organization = Organization.new(organization_params)
    authorize @organization

    if @organization.save
      # Automatically make creator an admin
      @organization.organization_memberships.create!(
        user: current_user,
        role: "admin",
        status: "active",
        joined_at: Time.current
      )
      redirect_to @organization, notice: "Organization created successfully."
    else
      render :new
    end
  end

  def analytics
    authorize @organization, :view_analytics?
    @analytics_data = @organization.analytics_data
    @membership_growth = @organization.organization_memberships
                                    .group_by_month(:created_at)
                                    .count
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :organization_type, :website)
  end
end

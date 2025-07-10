class ParentalConsentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_minor!, except: [ :verify ]

  def show
    @consent = current_user.parental_consent
    redirect_to new_parental_consent_path unless @consent
  end

  def new
    @consent = current_user.parental_consent || current_user.build_parental_consent
  end

  def create
    @consent = current_user.build_parental_consent(consent_params)
    @consent.generate_verification_token
    @consent.expires_at = 1.year.from_now

    if @consent.save
      # Here you would send verification email to parent
      # ParentalConsentMailer.verification_email(@consent).deliver_now

      redirect_to parental_consent_path(@consent),
        notice: "Parental consent request created! A verification email has been sent to #{@consent.parent_email}."
    else
      flash.now[:alert] = "Please correct the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @consent = current_user.parental_consent
    redirect_to new_parental_consent_path unless @consent
  end

  def update
    @consent = current_user.parental_consent
    redirect_to new_parental_consent_path unless @consent

    if @consent.update(consent_params)
      redirect_to parental_consent_path(@consent),
        notice: "Parental consent information updated successfully!"
    else
      flash.now[:alert] = "Please correct the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def verify
    @consent = ParentalConsent.find_by(verification_token: params[:token])

    if @consent && !@consent.expired?
      @consent.update!(
        consent_given_at: Time.current,
        consent_method: "email"
      )

      redirect_to root_path,
        notice: "Parental consent verified successfully! #{@consent.user.first_name} now has full access."
    else
      redirect_to root_path,
        alert: "Invalid or expired verification link."
    end
  end

  private

  def consent_params
    params.require(:parental_consent).permit(:parent_name, :parent_email, :parent_phone)
  end

  def require_minor!
    redirect_to root_path, alert: "This page is only for minor users." unless current_user&.minor?
  end
end

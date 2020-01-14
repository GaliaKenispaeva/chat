class Admin::TwoFactorsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def show
    unless current_user.otp_required_for_login?
      current_user.unconfirmed_otp_secret = User.generate_otp_secret
      current_user.save!
      @qr = RQRCode::QRCode.new(two_factor_otp_url).as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 5,
        standalone: true
      ).html_safe
      render 'new'
    end
  end

  def create
    permitted_params = params.require(:user).permit(:password, :otp_attempt)
    if current_user.activate_two_factor permitted_params
      redirect_to root_path, notice: "You have enabled Two Factor Auth"
    else
      render 'new'
    end
  end

  def destroy
    permitted_params = params.require(:user).permit :password
    if current_user.deactivate_two_factor(permitted_params)
      redirect_to root_path, notice: "You have disabled Two Factor Auth"
    else
      render 'show'
    end
  end

  private

  def two_factor_otp_url
    "otpauth://totp/%{app_id}?secret=%{secret}&issuer=%{app}" % {
      :secret => current_user.unconfirmed_otp_secret,
      :app    => "chatter",
      :app_id => "Chatter"
    }
  end
end

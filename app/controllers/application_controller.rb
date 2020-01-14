class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :custom_headers

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username, :otp_attempt])
    update_attrs = [:email, :password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

  def custom_headers
    response.set_header('Feature-Policy', 'vibrate self; sync-xhr self; camera none')
  end
end

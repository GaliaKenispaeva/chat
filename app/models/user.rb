class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :two_factor_authenticatable,
         :otp_secret_encryption_key => ENV['TWO_FACTOR_KEY']

  validates :username, uniqueness: true, presence: true

  has_many :room_users
  has_many :rooms, through: :room_users

  has_many :room_messages,
           dependent: :destroy
  

  def gravatar_url
    gravatar_id = Digest::MD5::hexdigest(email).downcase
    "https://gravatar.com/avatar/#{gravatar_id}.png"
  end

  def activate_two_factor params
    otp_params = { otp_secret: unconfirmed_otp_secret }
    if !valid_password?(params[:password])
      errors.add :password, :invalid
      false
    elsif !validate_and_consume_otp!(params[:otp_attempt], otp_params)
      errors.add :otp_attempt, :invalid
      false
    else
      activate_two_factor!
    end
  end
  
  def deactivate_two_factor params
    if !valid_password?(params[:password])
      errors.add :password, :invalid
      false
    else
      self.otp_required_for_login = false
      self.otp_secret = nil
      save
    end
  end
  
  private
  
  def activate_two_factor!
    self.otp_required_for_login = true
    self.otp_secret = unconfirmed_otp_secret
    self.unconfirmed_otp_secret = nil
    save
  end
end

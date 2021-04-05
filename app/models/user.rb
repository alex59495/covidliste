class User < ApplicationRecord
  rolify

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable

  encrypts :firstname
  encrypts :lastname
  encrypts :address
  encrypts :phone_number
  encrypts :email

  blind_index :email

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :address, presence: true
  validates :birthdate, presence: true
  validates :toc, presence: true, acceptance: true

  before_save :approximate_coords
  after_commit :geocode_address, if: :saved_change_to_address?

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  LATLNG_DECIMALS = 2

  def approximate_coords
    return if (self.lat.nil? || self.lon.nil?)
    self.lat = self.lat.round(LATLNG_DECIMALS)
    self.lon = self.lon.round(LATLNG_DECIMALS)
  end

  def geocode_address
    GeocodeJob.perform_later(self.id)
  end

  def full_name
    "#{firstname} #{lastname}"
  end

  def distance(lat, lon)
    Geocoder::Calculations.distance_between([lat, lon], [self.lat, self.lon]).round(1)
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end

  def confirmed?
    confirmed_at.present?
  end

  def super_admin?
    has_role?(:super_admin)
  end

  def admin?
    has_role?(:admin) || super_admin?
  end

  protected

  # Devise override
  def password_required?
    confirmed? ? super : false
  end
end

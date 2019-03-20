class Coupon < ApplicationRecord
  before_create :init_code

  def init_code
    self.code = SecureRandom.hex[0...6]

    true
  end

end
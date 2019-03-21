class Coupon < ApplicationRecord
  belongs_to :order, optional: true

  before_create :init_code

  validates :start_at, :expire_at, :price, presence: true

  include AASM

  aasm do
    state :valid_unused, initial: true
    state :valid_used
    state :invalid

    event :used do
      transitions form: :valid_unused,  to: :valid_used
    end

    event :cancel, after_commit: :update_order_id! do
      transitions from: :valid_used,     to: :valid_unused
    end

    event :admin_valid do
      transitions from: :valid_unused,   to: :invalid
    end

    event :admin_invalid do
      transitions from: :invalid,        to: :valid_unused
    end
  end

  def update_order_id!
    self.update_columns(order_id: "")
  end

  def init_code
    self.code = SecureRandom.hex[0...6]

    true
  end

end
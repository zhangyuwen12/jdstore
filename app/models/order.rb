class Order < ApplicationRecord
  has_many :product_lists
  belongs_to :user
  has_one :coupon

  before_create :generate_token
  after_create  :update_coupon

  validates :billing_name, presence: true
  validates :billing_address, presence: true
  validates :shipping_name, presence: true
  validates :shipping_address, presence: true

  include AASM

  aasm do
    state :order_placed, initial: true
    state :paid
    state :shipping
    state :shipped
    state :order_cancelled
    state :good_returned


    event :make_payment, after_commit: :pay! do
      transitions from: :order_placed, to: :paid
    end

    event :ship do
      transitions from: :paid,         to: :shipping
    end

    event :deliver do
      transitions from: :shipping,     to: :shipped
    end

    event :return_good do
      transitions from: :shipped,      to: :good_returned
    end

    event :cancel_order do
      transitions from: [:order_placed, :paid], to: :order_cancelled
    end
  end

  def generate_token
    self.token = SecureRandom.uuid
  end

  def set_payment_with!(method)
    self.update_columns(payment_method: method )
  end

  def pay!
    self.update_columns(is_paid: true )
  end

  def update_coupon
    @coupon = coupon.where(code: coupon_code, aasm_state: "valid_unused").first rescue nil
    self.update(coupon_amount: @coupon.amount) if @coupon.present? && @coupon.start_at <= created_at && @coupon.expire_at >= created_at && total > @coupon.amount

    if coupon_amount.present?
      self.update(total: total - coupon_amount)
      @coupon.used!
      @coupon.update(order_id: id)
    end
  end

  def total_amount
    total.to_i + coupon_amount.to_i
  end
end

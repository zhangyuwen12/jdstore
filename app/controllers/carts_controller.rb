class CartsController < ApplicationController
  def clean
    current_cart.clean!
    flash[:warning] = "已清空购物车"
    redirect_to carts_path
  end

  def checkout
    @order = Order.new
  end

  def coupon_amount
    @coupon = Coupon.where(code: params[:coupon_code], aasm_state: "valid_unused").first
    is_have_coupon = @coupon.present? && Time.now >= @coupon.start_at &&  Time.now <= @coupon.expire_at
    render json: {code: 200, message: is_have_coupon ? "优惠金额：#{@coupon.amount}" : "优惠失效或优惠码不存在" }
  end
end
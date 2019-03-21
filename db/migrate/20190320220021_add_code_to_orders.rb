class AddCodeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :coupon_code,   :string
    add_column :orders, :coupon_amount, :integer
  end
end

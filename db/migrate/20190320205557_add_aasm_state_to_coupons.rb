class AddAasmStateToCoupons < ActiveRecord::Migration[5.0]
  def change
    add_column :coupons, :order_id, :integer, default: "valid_no_used"
    add_column :coupons, :aasm_state, :string, default: "order_placed"
    add_index  :orders, :aasm_state
  end
end
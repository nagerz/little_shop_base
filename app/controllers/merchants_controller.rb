class MerchantsController < ApplicationController
  before_action :require_merchant, only: [:show]

  def index
    if current_admin?
      @merchants = User.where(role: 1)
    else
      @merchants = User.active_merchants
    end
    if current_user
      @user = current_user
      @top_five_merchants_by_fastest_fulfillment_state = @merchants.top_merchants_by_fulfilled_orders_fastest_state(@user, 5)
      @top_five_merchants_by_fastest_fulfillment_city = @merchants.top_merchants_by_fulfilled_orders_fastest_city(@user, 5)
    end

    @top_three_merchants_by_revenue = @merchants.top_merchants_by_revenue(3)
    @top_three_merchants_by_fulfillment = @merchants.top_merchants_by_fulfillment_time(3)
    @top_ten_merchants_by_items_this_month = @merchants.top_merchants_by_month_items(10)
    @top_ten_merchants_by_items_last_month = @merchants.top_merchants_by_month_items(10, 1.month.ago.month)
    @top_ten_merchants_by_noncancelled_orders_this_month = @merchants.top_merchants_by_fulfilled_orders(10)
    @top_ten_merchants_by_noncancelled_orders_last_month = @merchants.top_merchants_by_fulfilled_orders(10, 1.month.ago.month)
    @bottom_three_merchants_by_fulfillment = @merchants.bottom_merchants_by_fulfillment_time(3)
    @top_states_by_order_count = User.top_user_states_by_order_count(3)
    @top_cities_by_order_count = User.top_user_cities_by_order_count(3)
    @top_orders_by_items_shipped = Order.sorted_by_items_shipped(3)
  end

  def show
    @merchant = current_user
    @pending_orders = Order.pending_orders_for_merchant(current_user.id)
    @default_picture_items = @merchant.items.default_picture
    @unfulfilled_orders_count = Order.unfulfilled_orders_for_merchant_count(current_user.id)
    @unfulfilled_orders_value = Order.unfulfilled_orders_for_merchant_value(current_user.id)
  end
end

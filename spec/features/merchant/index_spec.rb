require 'rails_helper'

RSpec.describe "merchant index workflow", type: :feature do
  describe "As a visitor" do
    describe "displays all active merchant information" do
      before :each do
        @merchant_1, @merchant_2 = create_list(:merchant, 2)
        @inactive_merchant = create(:inactive_merchant)
      end
      scenario 'as a visitor' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
        @am_admin = false
      end
      scenario 'as an admin' do
        admin = create(:admin)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        @am_admin = true
      end
      after :each do
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_content(@merchant_1.name)
          expect(page).to have_content("#{@merchant_1.city}, #{@merchant_1.state}")
          expect(page).to have_content("Registered Date: #{@merchant_1.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        within("#merchant-#{@merchant_2.id}") do
          expect(page).to have_content(@merchant_2.name)
          expect(page).to have_content("#{@merchant_2.city}, #{@merchant_2.state}")
          expect(page).to have_content("Registered Date: #{@merchant_2.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        if @am_admin
          within("#merchant-#{@inactive_merchant.id}") do
            expect(page).to have_button('Enable Merchant')
          end
        else
          expect(page).to_not have_content(@inactive_merchant.name)
          expect(page).to_not have_content("#{@inactive_merchant.city}, #{@inactive_merchant.state}")
        end
      end
    end

    describe 'admins can enable/disable merchants' do
      before :each do
        @merchant_1 = create(:merchant)
        @admin = create(:admin)
      end
      it 'allows an admin to disable a merchant' do
        login_as(@admin)

        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Disable Merchant')
        end
        expect(current_path).to eq(merchants_path)

        visit logout_path
        login_as(@merchant_1)
        expect(current_path).to eq(login_path)
        expect(page).to have_content('Your account is inactive, contact an admin for help')

        visit logout_path
        login_as(@admin)
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Enable Merchant')
        end

        visit logout_path
        login_as(@merchant_1)
        expect(current_path).to eq(dashboard_path)

        visit logout_path
        login_as(@admin)
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_button('Disable Merchant')
        end
      end
    end

    describe "shows merchant statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u3 = create(:user, state: "IA", city: "Fairfield")
        u2 = create(:user, state: "OK", city: "OKC")
        u4 = create(:user, state: "IA", city: "Des Moines")
        u5 = create(:user, state: "IA", city: "Des Moines")
        u6 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant,7)
        i1 = create(:item, merchant_id: @m1.id)
        i2 = create(:item, merchant_id: @m2.id)
        i3 = create(:item, merchant_id: @m3.id)
        i4 = create(:item, merchant_id: @m4.id)
        i5 = create(:item, merchant_id: @m5.id)
        i6 = create(:item, merchant_id: @m6.id)
        i7 = create(:item, merchant_id: @m7.id)
        @o1 = create(:completed_order, user: u1)
        @o2 = create(:completed_order, user: u2)
        @o3 = create(:completed_order, user: u3)
        @o4 = create(:completed_order, user: u1)
        @o5 = create(:cancelled_order, user: u5)
        @o6 = create(:completed_order, user: u6)
        @o7 = create(:completed_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: i1, order: @o1, created_at: 5.minutes.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: @o2, created_at: 53.5.hours.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: @o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: @o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: @o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: @o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: @o7, created_at: 2.hours.ago)
      end

      it "top 3 merchants by price and quantity, with their revenue" do
        visit merchants_path

        within("#top-three-merchants-revenue") do
          expect(page).to have_content("#{@m7.name}: $192.00")
          expect(page).to have_content("#{@m6.name}: $147.00")
          expect(page).to have_content("#{@m3.name}: $48.00")
        end
      end

      it "top 3 merchants who were fastest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#top-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m1.name}: 00 hours 05 minutes")
          expect(page).to have_content("#{@m7.name}: 02 hours 00 minutes")
          expect(page).to have_content("#{@m2.name}: 2 days 05 hours 30 minutes")
        end
      end

      it "worst 3 merchants who were slowest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#bottom-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m3.name}: 6 days 00 hours 00 minutes")
          expect(page).to have_content("#{@m6.name}: 3 days 00 hours 00 minutes")
          expect(page).to have_content("#{@m2.name}: 2 days 05 hours 30 minutes")
        end
      end

      it "top 3 states where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-states-by-order") do
          expect(page).to have_content("IA: 3 orders")
          expect(page).to have_content("CO: 2 orders")
          expect(page).to have_content("OK: 1 order")
          expect(page).to_not have_content("OK: 1 orders")
        end
      end

      it "top 3 cities where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-cities-by-order") do
          expect(page).to have_content("Des Moines, IA: 2 orders")
          expect(page).to have_content("Fairfield, CO: 2 orders")
          expect(page).to have_content("Fairfield, IA: 1 order")
          expect(page).to_not have_content("Fairfield, IA: 1 orders")
        end
      end

      it "top 3 orders by quantity of items shipped, plus their quantities" do
        visit merchants_path

        within("#top-orders-by-items-shipped") do
          expect(page).to have_content("Order #{@o7.id}: 16 items")
          expect(page).to have_content("Order #{@o6.id}: 14 items")
          expect(page).to have_content("Order #{@o3.id}: 8 items")
        end
      end
    end

    describe "shows advanced merchant statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u2 = create(:user, state: "IA", city: "Fairfield")
        u3 = create(:user, state: "OK", city: "OKC")
        u4 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7, @m8, @m9, @m10, @m11, @m12, @m13, @m14, @m15, @m16 = create_list(:merchant, 16)
        i1 = create(:item, merchant_id: @m1.id)
        i2 = create(:item, merchant_id: @m2.id)
        i3 = create(:item, merchant_id: @m3.id)
        i4 = create(:item, merchant_id: @m4.id)
        i5 = create(:item, merchant_id: @m5.id)
        i6 = create(:item, merchant_id: @m6.id)
        i7 = create(:item, merchant_id: @m7.id)
        i8 = create(:item, merchant_id: @m8.id)
        i9 = create(:item, merchant_id: @m9.id)
        i10 = create(:item, merchant_id: @m10.id)
        i11 = create(:item, merchant_id: @m11.id)
        i12 = create(:item, merchant_id: @m12.id)
        i13 = create(:item, merchant_id: @m13.id)
        i14 = create(:item, merchant_id: @m14.id)
        i15 = create(:item, merchant_id: @m15.id)
        i16 = create(:item, merchant_id: @m16.id)
        o1, o2, o3, o4, o5, o6 , o7, o8 = create_list(:completed_order, 8, user: u1)
        o9 = create(:order, user: u1)
        o10 = create(:cancelled_order, user: u1)
        o11 = create(:completed_order, user: u2)
        o12 = create(:completed_order, user: u3)
        o13 = create(:order, user: u4)


        #Order_items updated_at (fulfilled) current time (this month)
        oi1 = create(:fulfilled_order_item, item: i4, order: o1, quantity: 1, created_at: 200.days.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: o1, quantity: 1, created_at: 200.days.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: o1, quantity: 1, created_at: 200.days.ago)
        oi4 = create(:fulfilled_order_item, item: i3, order: o2, quantity: 1, created_at: 200.days.ago)
        oi5 = create(:fulfilled_order_item, item: i2, order: o2, quantity: 1, created_at: 200.days.ago)
        oi6 = create(:fulfilled_order_item, item: i4, order: o3, quantity: 1, created_at: 200.days.ago)
        oi7 = create(:fulfilled_order_item, item: i3, order: o4, quantity: 1, created_at: 200.days.ago)
        oi8 = create(:fulfilled_order_item, item: i1, order: o5, quantity: 1, created_at: 200.days.ago)
        oi9 = create(:fulfilled_order_item, item: i3, order: o6, quantity: 1, created_at: 200.days.ago)
        oi10 = create(:fulfilled_order_item, item: i5, order: o6, quantity: 1, created_at: 200.days.ago)

        #Item not fulfilled this month
        oi11 = create(:fulfilled_order_item, item: i1, order: o7, created_at: 200.days.ago, updated_at: 2.months.ago, quantity: 5)
        oi34 = create(:fulfilled_order_item, item: i1, order: o7, created_at: 400.days.ago, updated_at: 1.year.ago, quantity: 5)
        #Item unfulfilled
        oi12 = create(:order_item, item: i1, order: o8, created_at: 200.days.ago, quantity: 5)
        oi13 = create(:order_item, item: i1, order: o8, created_at: 200.days.ago, updated_at: 1.month.ago, quantity: 5)
        #Order pending
        oi14 = create(:fulfilled_order_item, item: i11, order: o9, created_at: 200.days.ago, quantity: 5)
        oi15 = create(:fulfilled_order_item, item: i11, order: o9, created_at: 200.days.ago, updated_at: 1.month.ago, quantity: 5)
        #Order cancelled
        oi16 = create(:fulfilled_order_item, item: i1, order: o10, created_at: 200.days.ago, quantity: 5)
        oi17 = create(:fulfilled_order_item, item: i1, order: o10, created_at: 200.days.ago, updated_at: 1.month.ago, quantity: 5)

        #Order_items updated_at (fulfilled) 1 month ago (last month)
        oi18 = create(:fulfilled_order_item, item: i9, order: o1, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi19 = create(:fulfilled_order_item, item: i7, order: o1, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi20 = create(:fulfilled_order_item, item: i8, order: o1, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi21 = create(:fulfilled_order_item, item: i8, order: o2, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi22 = create(:fulfilled_order_item, item: i7, order: o2, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi23 = create(:fulfilled_order_item, item: i9, order: o3, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi24 = create(:fulfilled_order_item, item: i8, order: o4, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi25 = create(:fulfilled_order_item, item: i6, order: o5, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi26 = create(:fulfilled_order_item, item: i8, order: o6, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi27 = create(:fulfilled_order_item, item: i10, order: o6, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)

        oi28 = create(:fulfilled_order_item, item: i11, order: o11, quantity: 1, created_at: 220.days.ago, updated_at: 1.month.ago)
        oi29 = create(:fulfilled_order_item, item: i12, order: o11, quantity: 1, created_at: 220.days.ago, updated_at: 1.month.ago)
        oi30 = create(:fulfilled_order_item, item: i13, order: o12, quantity: 1, created_at: 210.days.ago, updated_at: 1.month.ago)
        oi31 = create(:fulfilled_order_item, item: i14, order: o12, quantity: 1, created_at: 210.days.ago, updated_at: 1.month.ago)
        oi32 = create(:fulfilled_order_item, item: i15, order: o13, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi33 = create(:fulfilled_order_item, item: i16, order: o13, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
      end

      it "top 10 merchants by month items, this month" do
        visit merchants_path

        within("#top-ten-merchants-items-this-month") do
          expect(page).to have_content("#{@m3.name}: 4 Items")
          expect(page).to have_content("#{@m2.name}: 2 Items")
          expect(page).to have_content("#{@m4.name}: 2 Items")
          expect(page).to have_content("#{@m1.name}: 1 Item")
          expect(page).to have_content("#{@m5.name}: 1 Item")
        end
      end

      it "top 10 merchants by month items, last month" do
        visit merchants_path

        within("#top-ten-merchants-items-last-month") do
          expect(page).to have_content("#{@m8.name}: 4 Items")
          expect(page).to have_content("#{@m9.name}: 2 Items")
          expect(page).to have_content("#{@m7.name}: 2 Items")
          expect(page).to have_content("#{@m6.name}: 1 Item")
          expect(page).to have_content("#{@m10.name}: 1 Item")
          expect(page).to have_content("#{@m12.name}: 1 Item")
          expect(page).to have_content("#{@m13.name}: 1 Item")
          expect(page).to have_content("#{@m14.name}: 1 Item")
          expect(page).to have_content("#{@m15.name}: 1 Item")
          expect(page).to have_content("#{@m16.name}: 1 Item")
        end
      end

      it "top 10 merchants by month non-cancelled orders, this month" do
        visit merchants_path

        within("#top-ten-merchants-noncancelled-this-month") do
          expect(page).to have_content("#{@m11.name}: 5 Items")
          expect(page).to have_content("#{@m3.name}: 4 Items")
          expect(page).to have_content("#{@m2.name}: 2 Items")
          expect(page).to have_content("#{@m4.name}: 2 Items")
          expect(page).to have_content("#{@m1.name}: 1 Item")
          expect(page).to have_content("#{@m5.name}: 1 Item")
        end
      end

      it "top 10 merchants by month non-cancelled orders, last month" do
        visit merchants_path

        within("#top-ten-merchants-noncancelled-last-month") do
          expect(page).to have_content("#{@m11.name}: 5 Items")
          expect(page).to have_content("#{@m8.name}: 4 Items")
          expect(page).to have_content("#{@m9.name}: 2 Items")
          expect(page).to have_content("#{@m7.name}: 2 Items")
          expect(page).to have_content("#{@m6.name}: 1 Item")
          expect(page).to have_content("#{@m10.name}: 1 Item")
          expect(page).to have_content("#{@m12.name}: 1 Item")
          expect(page).to have_content("#{@m13.name}: 1 Item")
          expect(page).to have_content("#{@m14.name}: 1 Item")
          expect(page).to have_content("#{@m15.name}: 1 Item")
        end
      end

    end
  end
end

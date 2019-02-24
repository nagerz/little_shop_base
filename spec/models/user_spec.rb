require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    # as user
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders)}
    # as merchant
    it { should have_many :items }
  end

  describe 'class methods' do
    it ".active_merchants" do
      active_merchants = create_list(:merchant, 3)
      inactive_merchant = create(:inactive_merchant)

      expect(User.active_merchants).to eq(active_merchants)
    end

    describe "statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u2 = create(:user, state: "OK", city: "OKC")
        u3 = create(:user, state: "IA", city: "Fairfield")
        u4 = create(:user, state: "IA", city: "Des Moines")
        u5 = create(:user, state: "IA", city: "Des Moines")
        u6 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant, 7)
        i1 = create(:item, merchant_id: @m1.id)
        i2 = create(:item, merchant_id: @m2.id)
        i3 = create(:item, merchant_id: @m3.id)
        i4 = create(:item, merchant_id: @m4.id)
        i5 = create(:item, merchant_id: @m5.id)
        i6 = create(:item, merchant_id: @m6.id)
        i7 = create(:item, merchant_id: @m7.id)
        o1 = create(:completed_order, user: u1)
        o2 = create(:completed_order, user: u2)
        o3 = create(:completed_order, user: u3)
        o4 = create(:completed_order, user: u1)
        o5 = create(:cancelled_order, user: u5)
        o6 = create(:completed_order, user: u6)
        o7 = create(:completed_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: i1, order: o1, created_at: 1.days.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: o2, created_at: 7.days.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: o7, created_at: 2.days.ago)


        #
        # oi16 = create(:fulfilled_order_item, item: i5, order: o1, created_at: 200.days.ago, updated_at: 30.days.ago)
        # oi17 = create(:fulfilled_order_item, item: i6, order: o1, created_at: 200.days.ago, updated_at: 30.days.ago)
        # oi18 = create(:fulfilled_order_item, item: i7, order: o1, created_at: 200.days.ago, updated_at: 30.days.ago)
        # oi19 = create(:fulfilled_order_item, item: i5, order: o2, created_at: 200.days.ago, updated_at: 30.days.ago)
        # oi20 = create(:fulfilled_order_item, item: i6, order: o2, created_at: 200.days.ago, updated_at: 30.days.ago)
        # oi21 = create(:fulfilled_order_item, item: i5, order: o3, created_at: 200.days.ago, updated_at: 30.days.ago)
        # oi22 = create(:fulfilled_order_item, item: i7, order: o4, created_at: 200.days.ago, updated_at: 30.days.ago)
        # oi23 = create(:fulfilled_order_item, item: i4, order: o5, created_at: 200.days.ago, updated_at: 30.days.ago)

        #oi24 = create(:order_item, item: i7, order: o3, created_at: 200.days.ago, updated_at: )
      end
      it ".merchants_sorted_by_revenue" do
        expect(User.merchants_sorted_by_revenue).to eq([@m7, @m6, @m3, @m2, @m1])
      end

      it ".top_merchants_by_revenue()" do
        expect(User.top_merchants_by_revenue(3)).to eq([@m7, @m6, @m3])
      end

      it ".merchants_sorted_by_fulfillment_time" do
        expect(User.merchants_sorted_by_fulfillment_time(10)).to eq([@m1, @m7, @m6, @m3, @m2])
      end

      it ".top_merchants_by_fulfillment_time" do
        expect(User.top_merchants_by_fulfillment_time(3)).to eq([@m1, @m7, @m6])
      end

      it ".bottom_merchants_by_fulfillment_time" do
        expect(User.bottom_merchants_by_fulfillment_time(3)).to eq([@m2, @m3, @m6])
      end

      it ".top_user_states_by_order_count" do
        expect(User.top_user_states_by_order_count(3)[0].state).to eq("IA")
        expect(User.top_user_states_by_order_count(3)[0].order_count).to eq(3)
        expect(User.top_user_states_by_order_count(3)[1].state).to eq("CO")
        expect(User.top_user_states_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_states_by_order_count(3)[2].state).to eq("OK")
        expect(User.top_user_states_by_order_count(3)[2].order_count).to eq(1)
      end

      it ".top_user_cities_by_order_count" do
        expect(User.top_user_cities_by_order_count(3)[0].state).to eq("CO")
        expect(User.top_user_cities_by_order_count(3)[0].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[0].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[1].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[1].city).to eq("Des Moines")
        expect(User.top_user_cities_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[2].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[2].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[2].order_count).to eq(1)
      end
    end

    describe "advanced-statistics" do
      before :each do
        @u1 = create(:user, state: "CO", city: "Fairfield")
        @u2 = create(:user, state: "IA", city: "Fairfield")
        @u3 = create(:user, state: "OK", city: "OKC")
        @u4 = create(:user, state: "IA", city: "Des Moines")
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
        o1, o2, o3, o4, o5, o6 , o7, o8 = create_list(:completed_order, 8, user: @u1)
        o9 = create(:order, user: @u1)
        o10 = create(:cancelled_order, user: @u1)
        o11 = create(:completed_order, user: @u2)
        o12 = create(:completed_order, user: @u3)
        o13 = create(:order, user: @u4)
        o14 = create(:cancelled_order, user: @u2)
        o15 = create(:cancelled_order, user: @u4)

        #Order_items updated_at (fulfilled) current time (this month)
        oi1 = create(:fulfilled_order_item, item: i4, order: o1, quantity: 1, created_at: 200.days.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: o1, quantity: 1, price: 1, created_at: 200.days.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: o1, quantity: 1, created_at: 200.days.ago)
        oi4 = create(:fulfilled_order_item, item: i3, order: o2, quantity: 1, created_at: 200.days.ago)
        oi5 = create(:fulfilled_order_item, item: i2, order: o2, quantity: 1, created_at: 200.days.ago)
        oi6 = create(:fulfilled_order_item, item: i4, order: o3, quantity: 1, created_at: 200.days.ago)
        oi7 = create(:fulfilled_order_item, item: i3, order: o4, quantity: 1, created_at: 200.days.ago)
        oi8 = create(:fulfilled_order_item, item: i1, order: o5, quantity: 1, created_at: 200.days.ago)
        oi9 = create(:fulfilled_order_item, item: i3, order: o6, quantity: 1, created_at: 200.days.ago)
        oi10 = create(:fulfilled_order_item, item: i5, order: o6, quantity: 1, created_at: 200.days.ago)
        #Item not fulfilled this or last month
        oi11 = create(:fulfilled_order_item, item: i1, order: o7, created_at: 200.days.ago, updated_at: 2.months.ago, quantity: 5)
        oi40 = create(:fulfilled_order_item, item: i1, order: o7, created_at: 400.days.ago, updated_at: 1.year.ago, quantity: 5)
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
        oi19 = create(:fulfilled_order_item, item: i7, order: o1, quantity: 1, price: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi20 = create(:fulfilled_order_item, item: i8, order: o1, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi21 = create(:fulfilled_order_item, item: i8, order: o2, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi22 = create(:fulfilled_order_item, item: i7, order: o2, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi23 = create(:fulfilled_order_item, item: i9, order: o3, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi24 = create(:fulfilled_order_item, item: i8, order: o4, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi25 = create(:fulfilled_order_item, item: i6, order: o5, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi26 = create(:fulfilled_order_item, item: i8, order: o6, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)
        oi27 = create(:fulfilled_order_item, item: i10, order: o6, quantity: 1, created_at: 200.days.ago, updated_at: 1.month.ago)

        #Order_items updated not in last 2 months and by users in different states/cities
        oi28 = create(:fulfilled_order_item, item: i11, order: o11, quantity: 1, created_at: 260.days.ago, updated_at: 100.days.ago)
        oi29 = create(:fulfilled_order_item, item: i12, order: o11, quantity: 1, created_at: 250.days.ago, updated_at: 100.days.ago)
        oi30 = create(:fulfilled_order_item, item: i13, order: o12, quantity: 1, created_at: 240.days.ago, updated_at: 100.days.ago)
        oi31 = create(:fulfilled_order_item, item: i14, order: o12, quantity: 1, created_at: 230.days.ago, updated_at: 100.days.ago)
        oi32 = create(:fulfilled_order_item, item: i15, order: o13, quantity: 1, created_at: 220.days.ago, updated_at: 100.days.ago)
        oi33 = create(:fulfilled_order_item, item: i16, order: o13, quantity: 1, created_at: 210.days.ago, updated_at: 100.days.ago)
        oi34 = create(:fulfilled_order_item, item: i1, order: o11, quantity: 1, created_at: 200.days.ago, updated_at: 100.days.ago)
        oi35 = create(:fulfilled_order_item, item: i2, order: o11, quantity: 1, created_at: 190.days.ago, updated_at: 100.days.ago)
        oi36 = create(:fulfilled_order_item, item: i3, order: o11, quantity: 1, created_at: 180.days.ago, updated_at: 100.days.ago)
        #Order_item by same merchant, another state
        oi37 = create(:fulfilled_order_item, item: i16, order: o1, quantity: 1, created_at: 110.days.ago, updated_at: 100.days.ago)
        #Order_item by same merchant, same state, cancelled order
        oi38 = create(:fulfilled_order_item, item: i16, order: o14, quantity: 1, created_at: 110.days.ago, updated_at: 100.days.ago)
        oi39 = create(:fulfilled_order_item, item: i16, order: o15, quantity: 1, created_at: 110.days.ago, updated_at: 100.days.ago)
      end

      #Month = current month(default)
      it ".merchants_sorted_by_month_items(current)" do
        expect(User.merchants_sorted_by_month_items).to eq([@m3, @m2, @m4, @m1, @m5])
      end

      it ".top_3_merchants_by_month_items(current)" do
        expect(User.top_merchants_by_month_items(3)).to eq([@m3, @m2, @m4])
      end

      it ".merchants_sorted_by_fulfilled_orders(current)" do
        expect(User.merchants_sorted_by_fulfilled_orders).to eq([@m11, @m3, @m5, @m1, @m4, @m2])
      end

      it ".top_3_merchants_by_fulfilled_orders(current)" do
        expect(User.top_merchants_by_fulfilled_orders(3)).to eq([@m11, @m3, @m5])
      end

      #Month = next month
      it ".merchants_sorted_by_month_items(last)" do
        expect(User.merchants_sorted_by_month_items(Time.now.month - 1)).to eq([@m8, @m7, @m9, @m6, @m10])
      end

      it ".top_3_merchants_by_month_items(last)" do
        expect(User.top_merchants_by_month_items(3, Time.now.month - 1)).to eq([@m8, @m7, @m9])
      end

      it ".merchants_sorted_by_fulfilled_orders(last)" do
        merchants= User.merchants_sorted_by_fulfilled_orders(Time.now.month - 1)

        expect(merchants).to eq([@m8, @m11, @m9, @m10, @m6, @m7])
        expect(merchants[0].total_revenue).to eq(136.5)
        expect(merchants[1].total_revenue).to eq(120)
        expect(merchants[2].total_revenue).to eq(63)
        expect(merchants[3].total_revenue).to eq(40.5)
        expect(merchants[4].total_revenue).to eq(37.5)
        expect(merchants[5].total_revenue).to eq(34)
      end

      it ".top_3_merchants_by_fulfilled_orders(last)" do
        merchants = User.top_merchants_by_fulfilled_orders(3, Time.now.month - 1)

        expect(merchants).to eq([@m8, @m11, @m9])
      end

      #Fastest by user state
      it ".merchants_sorted_by_fulfilled_orders_fastest_state()" do
        user_2 = @u2
        user_3 = @u3
        user_4 = @u4

        expect(User.merchants_sorted_by_fulfilled_orders_fastest_state(user_2)).to eq([@m3, @m2, @m1, @m16, @m15, @m12, @m11])
        expect(User.merchants_sorted_by_fulfilled_orders_fastest_state(user_3)).to eq([@m14, @m13])
        expect(User.merchants_sorted_by_fulfilled_orders_fastest_state(user_4)).to eq([@m3, @m2, @m1, @m16, @m15, @m12, @m11])
      end

      it ".top_3_merchants_by_fulfilled_orders_fastest_state()" do
        user_2 = @u2

        expect(User.top_merchants_by_fulfilled_orders_fastest_state(user_2, 3)).to eq([@m3, @m2, @m1])
      end

      #Fastest by user city
      it ".merchants_sorted_by_fulfilled_orders_fastest_city()" do
        user_2 = @u2
        user_3 = @u3
        user_4 = @u4

        expect(User.merchants_sorted_by_fulfilled_orders_fastest_city(user_2)).to eq([@m3, @m2, @m1, @m12, @m11])
        expect(User.merchants_sorted_by_fulfilled_orders_fastest_city(user_3)).to eq([@m14, @m13])
        expect(User.merchants_sorted_by_fulfilled_orders_fastest_city(user_4)).to eq([@m16, @m15])
      end

      it ".top_3_merchants_by_fulfilled_orders_fastest_city()" do
        user_2 = @u2

        expect(User.top_merchants_by_fulfilled_orders_fastest_city(user_2, 3)).to eq([@m3, @m2, @m1])
      end


    end
  end

  describe 'instance methods' do
    before :each do
      @u1 = create(:user, state: "CO", city: "Fairfield")
      @u2 = create(:user, state: "OK", city: "OKC")
      @u3 = create(:user, state: "IA", city: "Fairfield")
      u4 = create(:user, state: "IA", city: "Des Moines")
      u5 = create(:user, state: "IA", city: "Des Moines")
      u6 = create(:user, state: "IA", city: "Des Moines")
      @m1 = create(:merchant)
      @m2 = create(:merchant)
      @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i9 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i8 = create(:item, merchant_id: @m2.id, inventory: 20)
      o1 = create(:completed_order, user: @u1)
      o2 = create(:completed_order, user: @u2)
      o3 = create(:completed_order, user: @u3)
      o4 = create(:completed_order, user: @u1)
      o5 = create(:cancelled_order, user: u5)
      o6 = create(:completed_order, user: u6)
      @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
      @oi2 = create(:order_item, item: @i2, order: o2, quantity: 8, created_at: 7.days.ago)
      @oi3 = create(:order_item, item: @i2, order: o3, quantity: 6, created_at: 7.days.ago)
      @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
      @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
      @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
      @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
      @oi1.fulfill
      @oi2.fulfill
      @oi3.fulfill
      @oi4.fulfill
      @oi5.fulfill
      @oi6.fulfill
      @oi7.fulfill
    end

    it '.top_items_sold_by_quantity' do
      expect(@m1.top_items_sold_by_quantity(5)[0].name).to eq(@i2.name)
      expect(@m1.top_items_sold_by_quantity(5)[0].quantity).to eq(14)
      expect(@m1.top_items_sold_by_quantity(5)[1].name).to eq(@i3.name)
      expect(@m1.top_items_sold_by_quantity(5)[1].quantity).to eq(4)
      expect(@m1.top_items_sold_by_quantity(5)[2].name).to eq(@i4.name)
      expect(@m1.top_items_sold_by_quantity(5)[2].quantity).to eq(3)
      expect(@m1.top_items_sold_by_quantity(5)[3].name).to eq(@i1.name)
      expect(@m1.top_items_sold_by_quantity(5)[3].quantity).to eq(2)
      expect(@m1.top_items_sold_by_quantity(5)[4].name).to eq(@i6.name)
      expect(@m1.top_items_sold_by_quantity(5)[4].quantity).to eq(2)
    end

    it '.total_items_sold' do
      expect(@m1.total_items_sold).to eq(26)
    end

    it '.total_inventory_remaining' do
      expect(@m1.total_inventory_remaining).to eq(134)
    end

    it '.percent_of_items_sold' do
      expect(@m1.percent_of_items_sold).to eq(19.40)
    end

    it '.top_states_by_items_shipped' do
      expect(@m1.top_states_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_states_by_items_shipped(3)[0].quantity).to eq(13)
      expect(@m1.top_states_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_states_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_states_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_states_by_items_shipped(3)[2].quantity).to eq(5)
    end

    it '.top_cities_by_items_shipped' do
      expect(@m1.top_cities_by_items_shipped(3)[0].city).to eq("Fairfield")
      expect(@m1.top_cities_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_cities_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_cities_by_items_shipped(3)[1].city).to eq("OKC")
      expect(@m1.top_cities_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_cities_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_cities_by_items_shipped(3)[2].city).to eq("Fairfield")
      expect(@m1.top_cities_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_cities_by_items_shipped(3)[2].quantity).to eq(5)
    end

    it '.top_user_by_order_count' do
      expect(@m1.top_user_by_order_count.name).to eq(@u1.name)
      expect(@m1.top_user_by_order_count.count).to eq(2)
    end

    it '.top_user_by_item_count' do
      expect(@m1.top_user_by_item_count.name).to eq(@u3.name)
      expect(@m1.top_user_by_item_count.quantity).to eq(10)
    end

    it '.top_users_by_money_spent' do
      expect(@m1.top_users_by_money_spent(3)[0].name).to eq(@u3.name)
      expect(@m1.top_users_by_money_spent(3)[0].total).to eq(66.0)
      expect(@m1.top_users_by_money_spent(3)[1].name).to eq(@u2.name)
      expect(@m1.top_users_by_money_spent(3)[1].total).to eq(36.0)
      expect(@m1.top_users_by_money_spent(3)[2].name).to eq(@u1.name)
      expect(@m1.top_users_by_money_spent(3)[2].total).to eq(33.0)
    end
  end
end

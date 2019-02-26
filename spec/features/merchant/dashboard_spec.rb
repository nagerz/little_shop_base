require 'rails_helper'

RSpec.describe 'merchant dashboard' do
  before :each do
    @merchant = create(:merchant)
    @admin = create(:admin)
    @i1, @i2 = create_list(:item, 2, user: @merchant)
    @i2.update(image: "https://picsum.photos/200/300/?image=524")
    @o1, @o2 = create_list(:order, 2)
    @o3 = create(:completed_order)
    @o4 = create(:cancelled_order)
    create(:order_item, order: @o1, item: @i1, quantity: 1, price: 2)
    create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
    create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
    create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
    create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)

    @merchant2 = create(:merchant)
    @i3, @i4 = create_list(:item, 2, user: @merchant2, inventory: 10)
    @o5 = create(:completed_order)
    @o6 = create(:order)
    @o7 = create(:order)
    create(:order_item, order: @o5, item: @i3, quantity: 1, price: 2)
    create(:fulfilled_order_item, order: @o6, item: @i4, quantity: 4, price: 4)
    create(:order_item, order: @o6, item: @i3, quantity: 8, price: 4)
    create(:order_item, order: @o7, item: @i3, quantity: 8, price: 4)
    create(:order_item, order: @o7, item: @i4, quantity: 12, price: 4)
  end

  describe 'merchant user visits their profile' do
    describe 'shows merchant information' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path
      end
      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        visit admin_merchant_path(@merchant)
      end
      after :each do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content("Email: #{@merchant.email}")
        expect(page).to have_content("Address: #{@merchant.address}")
        expect(page).to have_content("City: #{@merchant.city}")
        expect(page).to have_content("State: #{@merchant.state}")
        expect(page).to have_content("Zip: #{@merchant.zip}")
      end
    end
  end

  describe 'merchant user with orders visits their profile' do
    before :each do
      #allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      login_as(@merchant)

      visit dashboard_path
    end
    it 'shows merchant information' do
      expect(page).to have_content(@merchant.name)
      expect(page).to have_content("Email: #{@merchant.email}")
      expect(page).to have_content("Address: #{@merchant.address}")
      expect(page).to have_content("City: #{@merchant.city}")
      expect(page).to have_content("State: #{@merchant.state}")
      expect(page).to have_content("Zip: #{@merchant.zip}")
    end

    it 'does not have a link to edit information' do
      expect(page).to_not have_link('Edit')
    end

    it 'shows pending order information' do
      within("#order-#{@o1.id}") do
        expect(page).to have_link(@o1.id)
        expect(page).to have_content(@o1.created_at)
        expect(page).to have_content(@o1.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o1.total_price_for_merchant(@merchant.id))
      end
      within("#order-#{@o2.id}") do
        expect(page).to have_link(@o2.id)
        expect(page).to have_content(@o2.created_at)
        expect(page).to have_content(@o2.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o2.total_price_for_merchant(@merchant.id))
      end
    end

    it 'does not show non-pending orders' do
      expect(page).to_not have_css("#order-#{@o3.id}")
      expect(page).to_not have_css("#order-#{@o4.id}")
    end

    describe 'shows a link to merchant items' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path
        click_link('Items for Sale')
        expect(current_path).to eq(dashboard_items_path)
      end
      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        visit admin_merchant_path(@merchant)
        click_link('Items for Sale')
        expect(current_path).to eq(admin_merchant_items_path(@merchant))
      end
    end

    describe 'shows a merchant to-do list' do
      it 'has a header' do
        expect(page).to have_content("To-do Tasks")
      end

      describe 'identifies items with default image' do
        it 'has a items with default picture list' do
          within '.default-picture-items' do
            expect(page).to have_content("Items Needing an Updated Picture:")
            expect(page).to_not have_content(@i1.name)
            expect(page).to have_link(@i2.name)
          end
        end

        it 'item names are a link to edit item form' do
          within '.default-picture-items' do
            expect(page).to have_link(@i2.name)
            click_link(@i2.name)
          end

          expect(current_path).to eq(edit_dashboard_item_path(@i2))
        end

        it 'doesnt show up if no items' do
          click_link("Log out")
          login_as(@merchant2)

          within '.dashboard-todo' do
            expect(page).to_not have_content("Items Needing an Updated Picture:")
          end
        end
      end

      describe 'has unfulfilled orders statistic' do
        it 'shows stat with number items and value' do
          within '.unfulfilled-items-worth' do
            expect(page).to have_content("You have 2 orders requiring attention worth $14.00")
            #expect(page).to have_link("Start fulfilling")
          end
        end

        it 'doesnt show up if no unfulfilled items' do
          click_link("Log out")
          login_as(@merchant2)

          within '.dashboard-todo' do
            expect(page).to_not have_content("requiring attention worth")
          end
        end
      end

      describe 'has inventory warning if order item exceeds inventory quantity' do
        it 'shows warning if any order item exceeds inventory quantity' do
          click_link("Log out")
          login_as(@merchant2)

          within '.unfulfilled-orders-table' do
            expect(page).to have_content("Notes")
            expect(page).to have_content(@o6.id)
            expect(page).to have_content(@o7.id)

            within "#order-#{@o6.id}" do
              within ".order-notes" do
                #expect(page).to_not have_content("symbol")
                expect(page).to_not have_content("Inventory Shortage")
              end
            end

            within "#order-#{@o7.id}" do
              within ".order-notes" do
                #expect(page).to have_content("symbol")
                expect(page).to have_content("Inventory Shortage")
              end
            end

          end
        end
      end


    end
  end
end

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :description }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).only_integer }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :order_items }
    it { should have_many(:orders).through(:order_items) }
  end

  describe 'class methods' do
    describe 'item popularity' do
      before :each do
        merchant = create(:merchant)
        @items = create_list(:item, 6, user: merchant)
        user = create(:user)
        @i7 = create(:item, user: merchant, image: "https://picsum.photos/200/300/?image=524")


        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: @items[3], quantity: 7)
        create(:fulfilled_order_item, order: order, item: @items[1], quantity: 6)
        create(:fulfilled_order_item, order: order, item: @items[0], quantity: 5)
        create(:fulfilled_order_item, order: order, item: @items[2], quantity: 3)
        create(:fulfilled_order_item, order: order, item: @items[5], quantity: 2)
        create(:fulfilled_order_item, order: order, item: @items[4], quantity: 1)
      end
      it '.item_popularity' do
        expect(Item.item_popularity(4, :desc)).to eq([@items[3], @items[1], @items[0], @items[2]])
        expect(Item.item_popularity(4, :asc)).to eq([@items[4], @items[5], @items[2], @items[0]])
      end
      it '.popular_items' do
        actual = Item.popular_items(3)
        expect(actual).to eq([@items[3], @items[1], @items[0]])
        expect(actual[0].total_ordered).to eq(7)
      end
      it '.unpopular_items' do
        actual = Item.unpopular_items(3)
        expect(actual).to eq([@items[4], @items[5], @items[2]])
        expect(actual[0].total_ordered).to eq(1)
      end
    end

    it '.default_picture_items' do
      actual = Item.default_picture_items
      expect(actual).to eq([@i7])
    end
    it '.low_inventory_items' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1, item2, item3, item4 = create_list(:item, 4, user: merchant1, inventory: 10)
      item5, item6 = create_list(:item, 2, user: merchant2, inventory: 10)

      user = create(:user)
      order1 = create(:order, user: user)
      order2 = create(:order, user: user)
      order3 = create(:order, user: user)
      order4 = create(:cancelled_order, user: user)

      create(:order_item, order: order1, item: item1, quantity: 7, price: 2)
      create(:order_item, order: order2, item: item1, quantity: 6, price: 2)
      create(:order_item, order: order1, item: item2, quantity: 3, price: 2)
      create(:order_item, order: order2, item: item2, quantity: 4, price: 2)
      create(:order_item, order: order3, item: item2, quantity: 5, price: 2)
      create(:order_item, order: order3, item: item3, quantity: 9, price: 2)
      #Should only factor previosly unfulfilled order items
      create(:fulfilled_order_item, order: order1, item: item3, quantity: 3, price: 2)
      create(:fulfilled_order_item, order: order3, item: item1, quantity: 3, price: 2)
      #Should only factor items in non-cancelled orders
      create(:order_item, order: order4, item: item3, quantity: 3, price: 2)
      #Should only factor items of current merchant
      create(:order_item, order: order1, item: item5, quantity: 2, price: 2)
      create(:order_item, order: order1, item: item5, quantity: 7, price: 2)

      expect(merchant1.items).to eq([item1, item2, item3, item4])
      expect(merchant2.items).to eq([item5, item6])

      low_items1 = merchant1.items.low_inventory_items
      low_items2 = merchant2.items.low_inventory_items

      expect(low_items1).to eq([item1, item2])
      expect(low_items2).to eq([])
      expect(low_items1[0].item_quantity).to eq(13)
      expect(low_items1[0].total_value).to eq(26)
      expect(low_items1[0].order_quantity).to eq(2)
      expect(low_items1[1].item_quantity).to eq(12)
      expect(low_items1[1].total_value).to eq(24)
      expect(low_items1[1].order_quantity).to eq(3)
    end
  end

  describe 'instance methods' do
    describe '.avg_time_to_fulfill' do
      scenario 'happy path, with orders' do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)
        order_1 = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order_1, item: item, quantity: 5, price: 2, created_at: 3.days.ago, updated_at: 1.day.ago)
        order_2 = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order_2, item: item, quantity: 5, price: 2, created_at: 1.days.ago, updated_at: 1.hour.ago)

        actual = item.avg_time_to_fulfill[0..13]
        expect(actual).to eq('1 day 11:30:00')
      end
      scenario 'sad path, no orders' do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)

        expect(item.avg_time_to_fulfill).to eq('n/a')
      end
    end
  end

  it '.ever_ordered?' do
    item_1, item_2, item_3, item_4, item_5 = create_list(:item, 5)

    order = create(:completed_order)
    create(:fulfilled_order_item, order: order, item: item_1, created_at: 4.days.ago, updated_at: 1.days.ago)

    order = create(:order)
    create(:fulfilled_order_item, order: order, item: item_2, created_at: 4.days.ago, updated_at: 1.days.ago)
    create(:order_item, order: order, item: item_3, created_at: 4.days.ago, updated_at: 1.days.ago)

    order = create(:order)
    create(:order_item, order: order, item: item_4, created_at: 4.days.ago, updated_at: 1.days.ago)

    expect(item_1.ever_ordered?).to eq(true)
    expect(item_2.ever_ordered?).to eq(false)
    expect(item_3.ever_ordered?).to eq(false)
    expect(item_4.ever_ordered?).to eq(false)
    expect(item_5.ever_ordered?).to eq(false)
  end
end

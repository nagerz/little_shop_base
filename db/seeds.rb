require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

OrderItem.destroy_all
Order.destroy_all
Item.destroy_all
User.destroy_all

admin = create(:admin)
user_1, user_2, user_3, user_4, user_5, user_6 = create_list(:user, 6)
merchant_1, merchant_2, merchant_3, merchant_4, merchant_5, merchant_6, merchant_7, merchant_8, merchant_9, merchant_10, merchant_11, merchant_12, merchant_13, merchant_14 = create_list(:merchant, 14)

inactive_merchant_1 = create(:inactive_merchant)
inactive_user_1 = create(:inactive_user)

item_1 = create(:item, user: merchant_1, image: "https://picsum.photos/200/300/?image=524")
item_2 = create(:item, user: merchant_1, image: "https://picsum.photos/200/300/?image=524")
item_3 = create(:item, user: merchant_1)
item_4 = create(:item, user: merchant_4)
item_5 = create(:item, user: merchant_5)
item_6 = create(:item, user: merchant_6)
item_7 = create(:item, user: merchant_7)
item_8 = create(:item, user: merchant_8)
item_9 = create(:item, user: merchant_9)
item_10 = create(:item, user: merchant_10)
item_11 = create(:item, user: merchant_11)
item_12 = create(:item, user: merchant_12)
item_13 = create(:item, user: merchant_13)
item_14 = create(:item, user: merchant_14)
item_15 = create(:item, user: merchant_2)
item_16 = create(:item, user: merchant_3)
create_list(:item, 10, user: merchant_1)
create_list(:item, 5, user: merchant_2)

inactive_item_1 = create(:inactive_item, user: merchant_1)
inactive_item_2 = create(:inactive_item, user: inactive_merchant_1)

Random.new_seed
rng = Random.new

order = create(:completed_order, user: user_1)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_1, price: 5, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order, item: item_2, price: 6, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order, item: item_3, price: 7, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order, item: item_4, price: 8, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
order2 = create(:completed_order, user: user_2)
create(:fulfilled_order_item, order: order2, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order2, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order2, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order2, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order2, item: item_1, price: 5, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order2, item: item_2, price: 6, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order2, item: item_3, price: 7, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order2, item: item_4, price: 8, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
order3 = create(:completed_order, user: user_3)
create(:fulfilled_order_item, order: order3, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order3, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order3, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order3, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order3, item: item_1, price: 5, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order3, item: item_2, price: 6, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order3, item: item_3, price: 7, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
create(:fulfilled_order_item, order: order3, item: item_4, price: 8, quantity: 1, created_at: (rng.rand(43)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_1)
create(:fulfilled_order_item, order: order, item: item_5, price: 8, quantity: 1, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_1)
create(:fulfilled_order_item, order: order, item: item_6, price: 10, quantity: 2, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_1)
create(:fulfilled_order_item, order: order, item: item_7, price: 2, quantity: 10, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_1)
create(:fulfilled_order_item, order: order, item: item_8, price: 4, quantity: 11, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_2)
create(:fulfilled_order_item, order: order, item: item_9, price: 3, quantity: 70, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_3)
create(:fulfilled_order_item, order: order, item: item_10, price: 5, quantity: 10, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_2)
create(:fulfilled_order_item, order: order, item: item_11, price: 7, quantity: 15, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_1)
create(:fulfilled_order_item, order: order, item: item_12, price: 7, quantity: 15, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_2)
create(:fulfilled_order_item, order: order, item: item_13, price: 17, quantity: 155, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_3)
create(:fulfilled_order_item, order: order, item: item_14, price: 27, quantity: 367, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_2)
create(:fulfilled_order_item, order: order, item: item_15, price: 37, quantity: 30, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)
order = create(:completed_order, user: user_3)
create(:fulfilled_order_item, order: order, item: item_16, price: 2, quantity: 67, created_at: (rng.rand(100)+1).days.ago, updated_at: rng.rand(39).days.ago)

# pending order
order = create(:order, user: user_1)
create(:order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:order_item, order: order, item: item_3, price: 1, quantity: 5)
create(:order_item, order: order, item: item_4, price: 1, quantity: 3)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).days.ago, updated_at: rng.rand(23).hours.ago)
order = create(:order, user: user_2)
create(:order_item, order: order, item: item_2, price: 3, quantity: 100)
create(:order_item, order: order, item: item_3, price: 1, quantity: 5)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).days.ago, updated_at: rng.rand(23).hours.ago)
order = create(:order, user: user_3)
create(:order_item, order: order, item: item_1, price: 2, quantity: 5)
create(:order_item, order: order, item: item_2, price: 1, quantity: 4)
create(:order_item, order: order, item: item_3, price: 1, quantity: 7)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).days.ago, updated_at: rng.rand(23).hours.ago)
order = create(:order, user: user_4)
create(:order_item, order: order, item: item_5, price: 11, quantity: 17)
create(:order_item, order: order, item: item_2, price: 12, quantity: 45)
create(:order_item, order: order, item: item_3, price: 1, quantity: 75)
order = create(:order, user: user_4)
create(:order_item, order: order, item: item_5, price: 11, quantity: 17)
create(:order_item, order: order, item: item_2, price: 12, quantity: 45)
create(:order_item, order: order, item: item_3, price: 1, quantity: 75)
order = create(:order, user: user_5)
create(:order_item, order: order, item: item_10, price: 11, quantity: 7)
create(:order_item, order: order, item: item_12, price: 12, quantity: 5)
create(:order_item, order: order, item: item_1, price: 1, quantity: 80)
order = create(:order, user: user_1)
create(:order_item, order: order, item: item_10, price: 13, quantity: 2)

order = create(:cancelled_order, user: user_1)
create(:order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order = create(:completed_order, user: user_1)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(4)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)





puts 'seed data finished'
puts "Users created: #{User.count.to_i}"
puts "Orders created: #{Order.count.to_i}"
puts "Items created: #{Item.count.to_i}"
puts "OrderItems created: #{OrderItem.count.to_i}"

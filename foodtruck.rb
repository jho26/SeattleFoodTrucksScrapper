# Foodtruck Object
#!/usr/bin/ruby

require 'open-uri'
require 'json'

class Dish
    def initialize(name, description, price)
        @name = name
        @description = description
        @price = price
    end

    def getItem
        @name
    end

    def to_s
        inspect
    end

    def inspect
        "Item: #{@name}, #{@description}, #{@price})\n"
    end
end

# Class for Food Truck
class Foodtruck 

    $API_HOST = 'https://www.seattlefoodtruck.com/api'

    def initialize(name, food_categories, featured_photo, id)
        @name = name
        @food_categories = food_categories.map(&:clone)
        @featured_photo = featured_photo
        @id = id
        @menu = addMenu(id)
    end

    def getMenu
        @menu
    end

    def getName
        @name
    end

    def getID
        @id
    end

    def addMenu(id)
        url = $API_HOST + '/trucks/' + id.to_s
        json = open(url).read
        obj = JSON.parse(json)
        menu = Array.new
    
        obj["menu_items"].each do |item|
            name =  item["name"]
            description =  item["description"]
            price = item["price"]
            # puts "#{name}, #{description}, #{price}"
            # get menu items
            temp = Dish.new(name, description, price)
            menu.push(temp)
        end
    end

    def to_s
        inspect
    end

    def inspect
        "#{@name}, #{@food_categories}, #{@menu}"
    end
end


# Restaurant Object
#!/usr/bin/ruby


class Restaurant 

    def initialize(name, food_categories, featured_photo)
        @name = name
        @food_categories = food_categories.map(&:clone)
        @featured_photo = featured_photo
    end
end
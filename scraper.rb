# scraper.rb
# Extract and present data from the Seattle food truck website
# Parse JSON into some useful information
# Key Features
#
# Display food truck info in Bellevue:Barnes and Nobel
# Able to provide food truck info on current day
# Able to provide food truck info on a specific day as specified by a user
# Information of food truck should be easy to read
#
# Author: Jonathan Ho

#!/usr/bin/ruby

require 'open-uri'
require 'rubygems'
require 'json'
require 'pp'
require 'time'

require './restaurant.rb'

# GLOBAL VARIABLES
$IMAGE_HOST = 'https://s3-us-west-2.amazonaws.com/seattlefoodtruck-uploads-prod/'
$API_HOST = 'https://www.seattlefoodtruck.com/api'

# Returns Location ID from user input location
def getLocationID
    puts "Enter a neighborhood name"
    neighborhood = gets.downcase
    url = $API_HOST + '/locations?include_events=true&include_trucks=true&only_with_events=true&with_active_trucks=true&neighborhood=' + neighborhood + '&with_events_on_day=' + Date.today.strftime("%Y-%m-%d") + 'T12%3A00%3A00-07%3A00'
    json = open(url).read
    objs = JSON.parse(json)

    puts "\nList of food trucks in #{neighborhood}"
    puts "Name \t\t ID"
    objs["locations"].each do |item|
        name = item["name"]
        uid = item["uid"]
        puts "#{name} \t #{uid}"
    end
    puts "Enter the ID of the desired food truck: "
    locationID = gets
end

# Returns total number of pages using locationID
def getTotalPages(locationID)
    url = $API_HOST + '/events?page=1&for_locations=' + locationID.to_s + '&with_active_trucks=true&include_bookings=true&with_booking_status=approved'
    json = open(url).read
    objs = JSON.parse(json)
    totalpages = objs["pagination"]["total_pages"]
end

# print out all results using locationID
def getResults(locationID, total)
    page = 1
    bookings = Hash.new([])
    
    begin 
        url = $API_HOST + '/events?page=' + page.to_s + '&for_locations=' + locationID.to_s + '&with_active_trucks=true&include_bookings=true&with_booking_status=approved'
        json = open(url).read
        objs = JSON.parse(json)

        objs["events"].each do |obj|
            time = Time.parse(obj["start_time"]).strftime("%Y-%m-%d")
            #puts "\n"
            #totalcount -= 1

            list = Array.new
            # parse restaurants in the booking
            obj["bookings"].each do |item|
                name =  item["truck"]["name"]
                arr =  item["truck"]["food_categories"]
                photo = $IMAGE_HOST + item["truck"]["featured_photo"].to_s
                id = item["truck"]["id"]
                r1 = Foodtruck.new(name, arr, photo, id)
                list.push(r1)
            end
            bookings[time] = list
        end
        puts "Getting data ... #{page}/#{total}"
        page += 1
    #end while page <= 1
    end while page <= total

    return bookings
end



# print records
def printRecords(bookings)
    bookings.each do |key, value|
        puts "#{key}:#{value}"
        puts "\n"
    end
end

# returns food truck info on current day
def todaysMenu(bookings)
    puts "#{bookings[Date.today.strftime("%Y-%m-%d")]}"
end

# returns food truck info on current day
def futureMenu(bookings, date)
    if date < Date.today
        return "Unable to return past entries"
    else
        return "#{bookings[date.strftime("%Y-%m-%d")]}"
    end
end

def search(bookings, phrase)
    bookings.each do |key, value|
        #puts value[0]
        #puts "inspect #{value}"
        value.each do |item|
            puts item.getName()
            menu = item.getMenu()
                menu.each do |dish|
                    #puts dish["name"]
                    #puts dish["description"]
                    
                end
            puts "\n"
        end
      end
end

# main method
locationID = getLocationID()
#total = getTotalPages(locationID)
bookings = getResults(locationID, 1)
#printRecords(bookings)

search(bookings, "pasta")

#puts "todays menu"
#todaysMenu(bookings)
#puts "yesterday's menu"
#puts futureMenu(bookings, Date.today - 1)
#puts "tomorrow's menu"
#puts futureMenu(bookings, Date.today + 1)


# unit test
# totalcount should be zero
# page should total to totalpages

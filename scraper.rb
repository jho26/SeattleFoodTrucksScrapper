# scraper.rb
# Extract and present data from the Seattle food truck website
# Parse JSON into some useful information
# Author: Jonathan Ho

#!/usr/bin/ruby

require 'open-uri'
require 'rubygems'
require 'json'
require 'pp'
require 'time'

require './restaurant.rb'

# GLOBAL VARIABLES
$imagehost = 'https://s3-us-west-2.amazonaws.com/seattlefoodtruck-uploads-prod/'

# Returns Location ID from user input location
def getLocationID
    puts "Enter a neighborhood name"
    neighborhood = gets
    url = 'https://www.seattlefoodtruck.com/api/locations?include_events=true&include_trucks=true&only_with_events=true&with_active_trucks=true&neighborhood=' + neighborhood + '&with_events_on_day=' + Date.today.strftime("%Y-%m-%d") + 'T12%3A00%3A00-07%3A00'
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
    puts "here #{locationID}"
    url = 'https://www.seattlefoodtruck.com/api/events?page=1&for_locations=' + locationID.to_s + '&with_active_trucks=true&include_bookings=true&with_booking_status=approved'
    json = open(url).read
    objs = JSON.parse(json)
    totalpages = objs["pagination"]["total_pages"]
end

# print out all results using locationID
def getResults(locationID)
    page = 0
    bookings = Hash.new([])
    total = getTotalPages(locationID)
    begin 
        url = 'https://www.seattlefoodtruck.com/api/events?page=' + page.to_s + '&for_locations=' + locationID.to_s + '&with_active_trucks=true&include_bookings=true&with_booking_status=approved'
        #puts url
        json = open(url).read
        objs = JSON.parse(json)

        objs["events"].each do |obj|
            time = Time.parse(obj["start_time"]).strftime("%Y-%m-%d")
            #puts "\n"
            #totalcount -= 1

            list = Array.new;
            # parse restaurants in the booking
            obj["bookings"].each do |item|
                name =  item["truck"]["name"]
                arr =  item["truck"]["food_categories"]
                photo = $imagehost.to_s + item["truck"]["featured_photo"].to_s
                r1 = Restaurant.new(name, arr, photo)
                list.push(r1);
            end
            bookings[time] = list
        end
        page += 1
    #end while page <= 1
    end while page <= total

    printRecords(bookings)
end

# print records
def printRecords(bookings)
    bookings.each do |key, value|
        puts "#{key}:#{value}"
        puts "\n"
    end
end

# main method
locationID = getLocationID()
getResults(locationID)

# unit test
# totalcount should be zero
# page should total to totalpages

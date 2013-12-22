class SearchController < ApplicationController
	def index
		queryString = params[:url].to_s
		imgoogle = ImageScraper::Client.new("https://www.google.com/search?site=&tbm=isch&q=#{params[:url]}")
		imFlickr = ImageScraper::Client.new("http://www.flickr.com/search/?q=#{params[:url]}")
		
		imgoogleI = imgoogle.image_urls 
		imFlickrI = imFlickr.image_urls

		response = imFlickrI+imgoogleI

		response = response.uniq
		hash = Hash.new

		response.each_with_index{ |item, index| hash[item] = "url"}
		
		@responseJSON = hash.to_json

		redis = Redis.new(:host => "localhost", :port => 6379)

		redis.set(queryString, @responseJSON)

		render "search/hi"
	end  
end

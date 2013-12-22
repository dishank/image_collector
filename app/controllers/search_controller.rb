class SearchController < ApplicationController
	def index
		queryString = params[:url].to_s
		#redis check
		if(redis.exists(params[:url])                        
            @responseJSON = redis.get(params[:url])
            render "search/hi"
        end	

		hash = Hash.new

		#Google
			imGoogle = ImageScraper::Client.new("https://www.google.com/search?site=&tbm=isch&q=#{queryString}")
			response = imGoogle.image_urls
		#Flickr
			FlickRaw.api_key=""
			FlickRaw.shared_secret=""
			new_b = flickr.places.find :query => queryString

			latitude = new_b[0]['latitude'].to_f
			longitude = new_b[0]['longitude'].to_f
			
			radius = 1
			args = {}
			args[:bbox] = "#{longitude - radius},#{latitude - radius},#{longitude + radius},#{latitude + radius}"

			# requires a limiting factor, so let's give it one
			args[:min_taken_date] = '2010-01-01 00:00:00'
			args[:accuracy] = 1 # the default is street only granularity [16], which most images aren't...
			discovered_pictures = flickr.photos.search args
			discovered_pictures.each{|p| response.push(FlickRaw.url p)}

		response.uniq
		response.each_with_index{ |item, index| hash[item] = "url"}
		

		@responseJSON = hash.to_json

		redis = Redis.new(:host => "localhost", :port => 6379)

		redis.set(queryString, @responseJSON)

		render "search/hi"
		
	end  
end

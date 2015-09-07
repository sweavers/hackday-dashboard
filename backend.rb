require 'sinatra'
require 'sinatra/reloader'
require 'json'

set :port, 8089
#set :environment, :development
set :environment, :production
set :server, 'webrick'


class DryCode
	def convert_json
		new_hash = {}
		@string = ''
		@mm = ''
		@ss = ''

		file = './public/results.json'
		json_file = File.read(file)

		converted_file = JSON.parse(json_file)

		converted_file.each do |item|
			item["result"].each do |result_item|
				if result_item[0] == "status"
					@status = result_item[1]
				end
				if result_item[0] == "sub_heading_body_1"
					@sub_heading_body_1 = result_item[1]
				end
				if result_item[0] == "sub_heading_body_2"
					@sub_heading_body_2 = result_item[1]
				end
			end
			captalised_profile = item["tile_title"]
			new_hash[captalised_profile] = {}

			new_hash[captalised_profile]['status'] = @status
			new_hash[captalised_profile]['sub_heading_body_1'] = @sub_heading_body_1
			new_hash[captalised_profile]['sub_heading_body_2'] = @sub_heading_body_2
		end
		new_hash = Hash[new_hash.sort]
		new_hash
	end

	def get_width (root)
		number_of_rows = 0
		width_value = 0

		if root == root.round
			number_of_rows = root
			width_value = 100.to_f/number_of_rows
		else
			number_of_rows = root + 1
			width_value = 100.to_f/root.to_i
		end

		@width_value = width_value.to_s
	end

	def get_height (root)
		number_of_rows = 0
		height_value = 0

		if root == root.round
			number_of_rows = root
			height_value = 100.to_f/number_of_rows
		else
			number_of_rows = root + 1
			height_value = 100.to_f/number_of_rows.round
		end

		@height_value = height_value.to_s
	end
end

class_obj = DryCode.new

get '/dashboard' do
	new_hash = class_obj.convert_json

	item_count = 0
	new_hash.each do |item|
		item_count = item_count + 1
	end

	root = Math.sqrt(item_count)

	width_value = class_obj.get_width(root)
	height_value = class_obj.get_height(root)

	@width_value = width_value
	@height_value = height_value
	@new_hash = new_hash
	erb :dashboard_view
end

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'net/http'
require 'uri'
require 'yaml'

set :port, 8089
set :environment, :development
#set :environment, :production
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

	def convert_yaml
		new_hash = {}
		config = YAML.load_file('./public/hostfile.yml')
		config['services'].each do |service|
			service.each do |name, uri|
				new_hash[name] = uri
			end
		end
		new_hash
	end

	def get_request (hostname)
		begin
			encoded_url = URI.encode("http://" + hostname.to_s)
			uri = URI.parse(encoded_url)
			request = Net::HTTP.new(uri)
			request.continue_timeout = 3
			request.keep_alive_timeout = 3
			request.open_timeout = 3
			request.read_timeout = 3
			response = Net::HTTP.get(uri)
			response

		rescue SystemCallError
			response = '{"status": "timeout"}'
			response
		end
	end
end

class_obj = DryCode.new

get '/dashboard' do
	new_hash = {}
	host_hash = class_obj.convert_yaml

	host_hash.each do |name, uri|
		status_code = ''
		response = class_obj.get_request(uri)
		converted_response = JSON.parse(response)
		converted_response.each do |status|
			if status[1] == 'ok'
				status_code = 'Green'
			else
				status_code = 'Red'
			end
		end

		new_hash[name] = status_code
	end

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

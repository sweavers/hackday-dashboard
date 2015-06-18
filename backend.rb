require 'sinatra'
require 'sinatra/reloader'
require 'json'

set :port, 8089
set :environment, :production
set :server, 'webrick'


class DryCode
	def convert_json
		new_hash = {}
		@string = ''
		@mm = ''
		@ss = ''

		file = './public/results_2.json'
		json_file = File.read(file)

		converted_file = JSON.parse(json_file)

		converted_file.each do |item|
			item["result"].each do |result_item|
				if result_item[0] == "this_week"
					@this_week = result_item[1]
				end
				if result_item[0] == "next_week"
					@next_week = result_item[1]
				end
				if result_item[0] == "rag_status"
					@rag_status = result_item[1]
				end
				if result_item[0] == "rag_justification"
					@rag_justification = result_item[1]
				end
				if result_item[0] == "risks"
					@risks = result_item[1]
				end
			end
			captalised_profile = item["wp_title"]
			new_hash[captalised_profile] = {}

			new_hash[captalised_profile]['this_week'] = @this_week
			new_hash[captalised_profile]['next_week'] = @next_week
			new_hash[captalised_profile]['rag_status'] = @rag_status
			new_hash[captalised_profile]['rag_justification'] = @rag_justification
			new_hash[captalised_profile]['risks'] = @risks
		end
		new_hash = Hash[new_hash.sort]
		new_hash
	end
end

class_obj = DryCode.new


get '/dashboard' do
	new_hash = {}
	@string = ''
	@mm = ''
	@ss = ''
	@pass_colour = "#26A65B"
	@fail_colour = "#D64541"
	@neutral_colour = "#EB9532"

	new_hash = class_obj.convert_json

	item_count = 0
	new_hash.each do |item|
		item_count = item_count + 1
	end

	root = Math.sqrt(item_count)

	number_of_rows = 0
	width_value = 0
	height_value = 0

	if root == root.round
		number_of_rows = root
		width_value = 100.to_f/number_of_rows
		height_value = 100.to_f/number_of_rows
	else
		number_of_rows = root + 1
		width_value = 100.to_f/root.to_i
		height_value = 100.to_f/number_of_rows.round
	end

	@width_value = width_value.to_s
	@height_value = height_value.to_s
	@item_count = item_count
	@pass_colour
	@fail_colour
	@new_hash = new_hash

	erb :dashboard_view
end



=begin
<% for i in 0..@item_count+@item_count
		if i%2 == 0%>
			.exitCode<%= i %> {
				background: <%= @pass_colour + ";"%>
				width:<%= @width_value + "%;"%>
				height:<%= @height_value + "vh;"%>
				float: left;
				border: 2px solid #BDC3C7;
				position:relative;
			}
	<% else %>
			.exitCode<%= i %> {
				background: <%= @fail_colour + ";"%>
				width:<%= @width_value + "%;"%>
				height:<%= @height_value + "vh;"%>
				float: left;
				border: 2px solid #BDC3C7;
				position:relative;
			}
	<% end %>
<% end %>
=end


=begin

post '/add_json' do
	if params["jsonString"].nil? || params["jsonString"].empty?
		puts 'No json was entered'
		@json_string = 'empty'
	else
		@json_string = params["jsonString"]
	end

	new_hash = {}
	pass_hash = {}
	fail_hash = {}
	@string = ''
	@mm = ''
	@ss = ''

	file = './public/results.json'
	json_file = File.read(file)

	file_trim = json_file.tr("]", "")
	json_trim = @json_string.tr("[", "")

	new_file = file_trim + ',' + json_trim
	converted_file = JSON.parse(new_file)

	File.write('./public/results.json', new_file)

	converted_file.each do |item|
		item["result"].each do |result_item|
			if result_item[0] == "duration"
				time = result_item[1]
				@mm, @ss = time.divmod(60)
				@ss = @ss.to_i.to_s
				if @ss.length == 1
					@ss = "0" + @ss
				end
			end
			if result_item[0] == "exitcode"
				@exitcode = result_item[1]
			end
		end
		captalised_profile = item["wp_title"].split("-").map(&:capitalize).join(" ")
		new_hash[captalised_profile] = @exitcode, @mm.to_s+":"+@ss
	end

	@new_hash = new_hash
	@pass_hash = pass_hash
	@fail_hash = fail_hash

	erb :dashboard_view
end

=end

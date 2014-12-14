require 'rubygems'
require 'sinatra'
require 'json'
require 'net/http'
require 'base64'
require 'date'

class HexApp < Sinatra::Base
  def hour_id(time = Time.now)
    (time.hour - 12)*2 + (time.min > 30 ? 2 : 1)
  end

  get '/' do
    today = Date.today
    post_data = {
      year:  Base64.encode64((today.year % 1000).to_s),
      month: Base64.encode64(today.month.to_s),
      day:   Base64.encode64(today.day.to_s)
    }
    request = Net::HTTP.post_form URI('https://serwer1472121.home.pl/fb_app/checkRes.php'), post_data
    json = JSON.parse(request.body)

    reserved = json.select { |r| r['hour_end_id'].to_i > hour_id && r['hour_start_id'].to_i <= hour_id }.map { |table| table['table_type_id'].to_i }
    free_tables = (0..13).to_a - reserved
    random_table = free_tables.sample unless free_tables.empty?  

    erb :index, locals: { random_table: random_table }
  end
end

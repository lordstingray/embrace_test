require 'logger'
require 'net/http'
require 'json'


logger = Logger.new(STDOUT)

API_KEY = 'JN8Y3FHFCWUFKFAVWAM9742HT'
BASE_API_URL = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline'
LOCATIONS = ['Copenhagen,Denmark', 'Lodz,Poland', 'Brussels,Belgium', 'Islamabad,Pakistan']

def median(data)
  data = data.sort
  entities = data.count
  center =  entities/2
  entities.even? ? (data[center] + data[center+1])/2 : data[center]
end

logger.info("Fetching data from visual crossing")

LOCATIONS.each do |location|
  uri = URI(BASE_API_URL + "/#{location}/last30days?key=#{API_KEY}")
  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    logger.info("City, Wind Avg, Wind Median, Temp Avg, Temp Median")
    res_data = JSON.parse(response.body)

    data_by_days = res_data.dig('days')

    temp_data = data_by_days.map { |d| d.dig('temp') }
    wind_speed_data = data_by_days.map { |d| d.dig('windspeed') }

    temp_avg = temp_data.sum/temp_data.count
    temp_median = median(temp_data.sort)

    wind_speed_avg = wind_speed_data.sum/wind_speed_data.count
    wind_speed_median = median(temp_data.sort)

    logger.info("#{location}, #{wind_speed_avg}, #{wind_speed_median}, #{temp_avg}, #{temp_median}")
  elsif response.code == '429'
    logger.warn(response.body)
  else
    logger.info("Sorry! Something went wrong while fetching data")
  end
end

require "dotenv/load"
require "http"
require "json"

begin
  pp "Hi there, please enter your location for the weather report"

  location = gets.chomp

  maps_request = "https://maps.googleapis.com/maps/api/geocode/json?address=" + location + "&key=" + ENV.fetch("MAPS_KEY")

  maps_raw = HTTP.get(maps_request)
  if maps_raw.status != 200
    raise "Error fetching location data. HTTP Status: #{maps_raw.status}"
  end

  maps_parsed = JSON.parse(maps_raw)
  if maps_parsed["status"] != "OK"
    raise "Error with location data: #{maps_parsed['status']} - #{maps_parsed['error_message']}"
  end

  loc = maps_parsed.fetch("results")[0].fetch("geometry").fetch("location")
  lng = loc.fetch("lng")
  lat = loc.fetch("lat")

  pirate_weather_url = "https://api.pirateweather.net/forecast/" + ENV.fetch("PIRATE_WEATHER_KEY") + "/" + lat.to_s + "," + lng.to_s

  weather_raw = HTTP.get(pirate_weather_url)
  if weather_raw.status != 200
    raise "Error fetching weather data. HTTP Status: #{weather_raw.status}"
  end

  weather_parsed = JSON.parse(weather_raw)
  if weather_parsed["currently"].nil? || weather_parsed["hourly"].nil?
    raise "Error parsing weather data: Missing 'currently' or 'hourly' key in response."
  end

  currently_hash = weather_parsed.fetch("currently")
  hourly_data = weather_parsed.fetch("hourly").fetch("data")[0]

  current_temp = currently_hash.fetch("temperature")
  hourly_summary = hourly_data.fetch("summary")
  hourly_temp = hourly_data.fetch("temperature")

  puts "The current temperature is " + current_temp.to_s + "°F."
  puts "The weather for the next hour: " + hourly_summary + " with a temperature of " + hourly_temp.to_s + "°F."

rescue KeyError => e
  puts "Missing expected data: #{e.message}"
rescue JSON::ParserError => e
  puts "Error parsing JSON response: #{e.message}"
rescue => e
  puts "An error occurred: #{e.message}"
end

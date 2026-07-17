class WeatherInformationService
  BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

  def initialize(zip_code)
    @zip_code = zip_code
    @api_key = ENV["OPENWEATHER_API_KEY"]
  end

  def fetch_weather
    # ensure zip code is present before trying to query the api
    return { error: "Weather information for zip code provided not found" } if @zip_code.blank?

    # check the cache for weather data for user inputted zip
    # if weather data is already cached, display that
    cached = Rails.cache.read("weather_#{@zip_code}")

    # add cached key to weather data hash so the controller knows to display notice
    return cached.merge!(cached: true) if cached.present?

    # if no data in the cache, use httparty gem to curl the base url
    # url is using openweathermap api
    # if searching by zip, no other params are required by the api,
    # so no need for parsing of city, state, etc
    response = HTTParty.get(BASE_URL, query: { zip: @zip_code, appid: @api_key, units: "imperial" })

    if response.success?
      # refine the data returned by the api to the five fields in parse_data
      result = parse_data(response.parsed_response)

      # cache weather data for zip code for 30 minutes
      Rails.cache.write("weather_#{@zip_code}", result, expires_in: 30.minutes)
      result
    else
      { error: "Weather information for zip code provided not found" }
    end
  rescue HTTParty::Error, StandardError => e
    { error: "Connection error: #{e.message}" }
  end

  private

  def parse_data(data)
    {
      temperature: data.dig("main", "temp"),
      low: data.dig("main", "temp_min"),
      high: data.dig("main", "temp_max"),
      description: data.dig("weather", 0, "description"),
      humidity: data.dig("main", "humidity")
    }
  end
end

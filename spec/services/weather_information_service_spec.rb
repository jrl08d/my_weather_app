require 'rails_helper'

RSpec.describe WeatherInformationService, type: :service do
  subject(:service) { described_class.new(zip_code) }

  describe '#fetch_weather' do
    context 'with no zip_code' do
      let(:zip_code) { nil }

      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
          .with(query: hash_including({ units: "imperial" }))
          .to_return(status: 400, body: "")
      end

      it 'raises error message' do
        # ensure service returns error message if user does not input a zip

        result = service.fetch_weather
        assert_includes result[:error], "Weather information for zip code provided not found"
      end
    end

    context 'with valid zip_code' do
      let!(:zip_code) { '33186' }
      let!(:api_key) { 'test_api_key' }
      let(:successful_response) {
        {
            "main" => {
            "temp" => 15.5,
            "temp_min" => 15,
            "temp_max" => 15.8,
            "humidity" => 72
          },
          "weather" => [
            {
              "description" => "partly cloudy"
            }
          ]
        }
      }

      before do
        Rails.cache.clear
        ENV["OPENWEATHER_API_KEY"] = api_key
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
          .with(query: { zip: zip_code, appid: api_key, units: "imperial" })
          .to_return(status: 200, body: successful_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns weather information' do
        result = service.fetch_weather

        assert_equal 15.5, result[:temperature]
        assert_equal 15, result[:low]
        assert_equal 15.8, result[:high]
        assert_equal "partly cloudy", result[:description]
        assert_equal 72, result[:humidity]
      end

      # ensure repeated calls hit the cache and avoid re requesting the external api
      # call the service twice and assert the api request only happens once
      it 'caches the weather data' do
        original_cache_store = Rails.cache
        Rails.cache = ActiveSupport::Cache::MemoryStore.new

        result1 = service.fetch_weather
        expect(result1[:temperature]).to eq(15.5)

        result2 = service.fetch_weather
        expect(result2[:temperature]).to eq(15.5)

        expect(WebMock).to have_requested(:get, "https://api.openweathermap.org/data/2.5/weather")
          .with(query: { zip: zip_code, appid: api_key, units: "imperial" })
          .once
      ensure
        Rails.cache = original_cache_store
      end
    end
  end
end

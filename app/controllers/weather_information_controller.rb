class WeatherInformationController < ApplicationController
  def index
  end

  def search
    if params[:zip_code].present?
      @weather_data = WeatherInformationService.new(params[:zip_code]).fetch_weather

      if @weather_data[:cached] == true
        flash[:notice] = "Diplaying Cached Weather Information"
      end
    end
  end
end

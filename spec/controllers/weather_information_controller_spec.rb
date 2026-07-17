require 'rails_helper'

RSpec.describe WeatherInformationController, type: :controller do
  describe 'GET #index' do
    it 'responds successfully' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #search' do
    context 'without zip_code' do
      it 'does not assign weather data instancce variable' do
        get :search
        expect(assigns(:weather_data)).to be_nil
      end
    end

    context 'with zip_code' do
      let(:zip) { '12345' }

      before do
        # stub the method call to the service to avoid calling the api url in test env
        allow(WeatherInformationService).to receive(:new).with(zip).and_return(service_double)
      end


      context 'when weather data is fetched from api' do
        let(:weather_data) { { temperature: 50 } }
        let(:service_double) { instance_double(WeatherInformationService, fetch_weather: weather_data) }

        it 'assings weather data instance variable' do
          get :search, params: { zip_code: zip }

          expect(assigns(:weather_data)).to eq(weather_data)
        end
      end

      context 'when weather data is fetched from cache' do
        let(:weather_data) { { temperature: 50, cached: true } }
        let(:service_double) { instance_double(WeatherInformationService, fetch_weather: weather_data) }

        it 'assings instance variable correctly and shows flash message' do
          get :search, params: { zip_code: zip }

          expect(flash[:notice]).to eq("Diplaying Cached Weather Information")
        end
      end
    end
  end
end

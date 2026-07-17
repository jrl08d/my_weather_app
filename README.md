# Weather App

Rails app that fetches weather for a given US ZIP code using the OpenWeatherMap API.


Getting the app up:

Install Ruby version 3.4.10 and bundler:

  `gem install bundler`

Install gems:

  `bundle`

Configure environment:

  go to https://openweathermap.org/ and sign up for their free api

  generate an api key

  place the api key in your `.env` file as `OPENWEATHER_API_KEY`

  

Start the Rails server:

  `rails server`


Visit http://localhost:3000 and use the search form to query by ZIP code.

The results should display:

  Temperature, Lows, Highs, Conditions, and Humidity

Ruby Version: ruby-3.4.10

Database:

no database is used in the app



Testing:

Run the test suite with:
  `bundle exec rspec`

Notes:

Weather info responses are cached for 30 minutes via Rails.cache.

`app/services/weather_information_service.rb` is where the main logic of the app lives. Here is where the api is interacted with.

`app/controllers/weather_information_controller.rb` is the main controller handling the information retrieved by the service class.

The relevant views live in `app/view/weather_information`

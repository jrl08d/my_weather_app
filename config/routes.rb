Rails.application.routes.draw do
  root "weather_information#index"
  get "search", to: "weather_information#search", as: "weather_information_search"
end

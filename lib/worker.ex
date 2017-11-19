require IEx;

defmodule Raindrop.Worker do
  @darksky_api_key Application.get_env(:raindrop, :darksky_api_key)
  @default_minutely_summary %{"minutely" => %{"summary" => ""}}

  def temperature_of(location) do
    location 
    |> reverse_geocode
    |> temperature_url
    |> get_forecast
    |> parse_response
    |> summarize(location)
  end

  def reverse_geocode(location) do
    location
    |> GoogleGeocodingApi.geo_location
    |> parse_geocoder_response
  end

  def parse_geocoder_response(%{"lat" => lat, "lng" => lon}), do: {lat, lon}
  def parse_geocoder_response({:error, _}), do: :error

  def temperature_url({lat, lon}), do: {:ok, "https://api.darksky.net/forecast/#{@darksky_api_key}/#{lat},#{lon}"}
  def temperature_url(_), do: :error

  def get_forecast({:ok, location_url}), do: HTTPoison.get(location_url)
  def get_forecast(_), do: :error

  def parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}), do: {:ok, JSON.decode!(body)}
  def parse_response(_), do: :error

  def summarize({:ok, weather_data}, location) do
    %{
      "currently" => %{"apparentTemperature" => temperature}, 
      "daily" => %{"summary" => daily_summary},
      "hourly" => %{"summary" => hourly_summary},
      "minutely" => %{"summary" => minutely_summary}
    } = merge_defaults(weather_data)

    IO.puts "Current temperature for #{location}: #{temperature}F\nSummary: #{daily_summary} #{hourly_summary} #{minutely_summary}"
  end

  def merge_defaults(map) do
    Map.merge(@default_minutely_summary, map)
  end
end

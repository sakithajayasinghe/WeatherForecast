//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
@MainActor
final class WeatherService {
    private let apiKey = "a26cd264d787d61abe6234a3f82a0501"

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        
        //build the url
        let baseURL = "https://api.openweathermap.org/data/3.0/onecall"
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "exclude", value: "minutely,hourly"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        //validate url
        guard let url = components?.url else {
            throw WeatherMapError.invalidURL(baseURL)
        }
        
        //perform network request with await
        do {
            let(data, response) = try await URLSession.shared.data(from: url)
            
            //validate http response status code
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherMapError.invalidResponse(statusCode: 0)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw WeatherMapError.invalidResponse(statusCode: httpResponse.statusCode)
            }
            
            //decode json response
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            return weatherResponse
        } catch let error as WeatherMapError{
            throw error
        } catch let decodingError as DecodingError{
            throw WeatherMapError.decodingError(decodingError)
        } catch {
            throw WeatherMapError.networkError(error)
        }
        
        
        
        
        
        
        
        
        
        
        // Constructs a URL for the OpenWeatherMap OneCall API using the provided coordinates and API key.
        // Performs an asynchronous network request using URLSession.
        // Validates the HTTP response status code.
        // Decodes the received JSON data into a `WeatherResponse` object, using a specific date decoding strategy.
        // Handles and throws specific `WeatherMapError` types for invalid URL, network failure, invalid response, and decoding errors.

        // DUMMY RETURN TO SATISFY COMPILER - you will have your own when the coding is done
        preconditionFailure("Stubbed function not implemented. Requires a WeatherResponse return.")
    }
}

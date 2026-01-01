//
//  Weather.swift
//  WeatherForecast
//
//  Created by sakitha on 2025-12-31.
//
import Foundation

//data model for current and forecase data
struct Weather: Identifiable {
    let id = UUID()
    
    //main whether information
    let date: Date
    let temperature: Double
    let feelsLike: Double
    let minTemp: Double?
    let maxTemp: Double?
    
    //weather condition
    let condition: String
    let description: String
    let icon: String
    
    //additional
    let humidity: Int
    let windSpeed: Double
    let pressure: Int
    let visibility: Int?
    let uvi: Double?
    //create weather from current data
    init(from current: Current){
        self.date = Date(timeIntervalSince1970: TimeInterval(current.dt))
        //convert kelvin to celcius
        self.temperature = current.temp - 273.15
        self.feelsLike = current.feelsLike - 273.15
        self.minTemp = nil
        self.maxTemp = nil
        
        let weatherInfo = current.weather.first ?? WeatherCondition(
            id: 0, main: "Unknown", description: "No Data", icon: "01d"
        )
        self.condition = weatherInfo.main
        self.description = weatherInfo.description
        self.icon = weatherInfo.icon
        
        self.humidity = current.humidity
        self.windSpeed = current.windSpeed
        self.pressure = current.pressure
        self.visibility = current.visibility
        self.uvi = nil //current does not have uvi.thats why it made nil
    }
    
    //create weather from daily to forecast data
    init(from daily: Daily){
        self.date = Date(timeIntervalSince1970: TimeInterval(daily.dt))
        self.temperature = daily.temp.day - 273.15
        self.feelsLike = daily.feelsLike.day - 273.15
        self.minTemp = daily.temp.min - 273.15
        self.maxTemp = daily.temp.max - 273.15
        
        let weatherInfo = daily.weather.first ?? WeatherCondition(
            id: 0, main: "Unknown", description: "No data", icon: "01d"
        )
        
        self.condition = weatherInfo.main
        self.description = weatherInfo.description
        self.icon = weatherInfo.icon
        
        self.humidity = daily.humidity
        self.windSpeed = daily.windSpeed
        self.pressure = daily.pressure
        self.visibility = nil  // Daily forecasts don't have visibility
        self.uvi = daily.uvi
    }
    
    
    
    
    
}


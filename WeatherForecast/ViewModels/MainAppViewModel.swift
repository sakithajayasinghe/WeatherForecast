//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit
import Combine

@MainActor
final class MainAppViewModel: ObservableObject {
    @Published var query = ""
    @Published var currentWeather: Weather?
    @Published var forecast: [Weather] = []
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var activePlaceName: String = ""
    private let defaultPlaceName = "London"
    @Published var selectedTab: Int = 0
    
    /// Create and use a WeatherService model (class) to manage fetching and decoding weather data
    private let weatherService = WeatherService()
    
    /// Create and use a LocationManager model (class) to manage address conversion and tourist places
    private let locationManager = LocationManager()
    
    /// Use a context to manage database operations
    private let context: ModelContext
    
    init(context: ModelContext) {
        // Initialize the ModelContext and attempt to fetch previously visited places from SwiftData, sorted by most recent use.
        // If no visited places exist (first launch), load the default location.
        // Otherwise, load the most recently used place.
        self.context = context
        
        // Corrected FetchDescriptor to include sorting by 'lastUsedAt' in reverse order.
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            self.visited = results
        }
        
        // First launch: no data → perform full London setup
        if visited.isEmpty {
            Task {
                await loadDefaultLocation()
            }
        } else if let mostRecent = visited.first {
            // Otherwise, load most recently used place
            Task {
                await loadLocation(fromPlace: mostRecent)
            }
        }
    }
    
    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
            appError = .missingData(message: "Please enter a valid location.")
            return
        }
        Task {
            do {
                // MARK: call loadLocation(byName:)
                try await loadLocation(byName: city)
                query = ""
            } catch {
                appError = .networkError(error)
            }
        }
    }
    func loadDefaultLocation() async {
        // Attempts to select and load the hardcoded default location name.
        // If an error occurs during selection, sets an app error.
        isLoading = true
        do {
            let geocodeResult = try await locationManager.geocodeAddress(defaultPlaceName)
            //first check if london already exist in visited places
            if let existingPlace = visited.first(where: { $0.name.lowercased() == defaultPlaceName.lowercased() }) {
                await loadLocation(fromPlace: existingPlace)
            } else {
                //if london not exist create new place and load all data
                let newPlace = Place(name: geocodeResult.name, latitude: geocodeResult.lat, longitude: geocodeResult.lon)
                
                //insert into context
                context.insert(newPlace)
                
                //load weather + POIs for this place
                try await loadAll(for: newPlace)
                
                //add to visited array
                visited.insert(newPlace, at: 0)
                
                try context.save()
            }
        } catch {
            if let weatherError = error as? WeatherMapError{
                appError = weatherError
            }else {
                appError = .networkError(error)
            }
            print("Failed to load default location: \(error)")
        }
        isLoading = false
    }
    
    func search() async throws {
        // If the query is not empty, calls `select(placeNamed:)` with the current query string.
    }
    
    /// Validate weather before saving a new place; create POI children once.
    func loadLocation(byName: String) async throws {
        // Sets loading state, then attempts to load data for the given place name.
        
        // 2. Otherwise, geocodes the fresh place name using `locationManager`.
        // 3. Fetches weather data using `weatherService` as a fail-fast check.
        // 4. Finds Points of Interest (POIs) using `locationManager`, converts them to `AnnotationModel`s, and associates them with the new `Place`.
        // 5. Inserts the new `Place` into the `visited` array and saves the context.
        // 6. Updates UI by setting `pois`, `activePlaceName`, and focusing the map.
        // 7. If any step fails, logs the error and reverts to the default location with an alert.
        isLoading = true
        
        do {
            // 1. Checks if the place is already in `visited` and, if so, loads all data for the existing `Place` object, updates its `lastUsedAt`, and saves the context.
            if let existingPlace = visited.first(where: {
                $0.name.lowercased() == byName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }){
                await loadLocation(fromPlace: existingPlace)
                //show alert
                appError = .missingData(message: "Location Loaded from Database")
                return
            }
            //place not exist geocode the place name
            let geocodeResult = try await locationManager.geocodeAddress(byName)
            
            //fetch weather data
            let weatherResponse = try await weatherService.fetchWeather(lat: geocodeResult.lat, lon: geocodeResult.lon)
            
            //find pois
            let pois = try await locationManager.findPOIs(lat: geocodeResult.lat, lon: geocodeResult.lon, limit: 5)
            
            //create new place object
            let newPlace = Place(name: geocodeResult.name, latitude: geocodeResult.lat, longitude: geocodeResult.lon)
            
            //create annotation model
            for poi in pois {
                poi.place = newPlace
                newPlace.pois.append(poi)
            }
            //insert place into context
            context.insert(newPlace)
            
            //load all data
            try await loadAll(for: newPlace)
            
            if !visited.contains(where: { $0.id == newPlace.id }) {
                visited.insert(newPlace, at: 0)
            }
            
            //save context
            try context.save()
            
            appError = .missingData(message: "Location saved Successfully")
        } catch {
            isLoading = false
            await revertToDefaultWithAlert(message: "Failed to load location: \(error.localizedDescription)")
            throw error
        }
        isLoading = false
    }
    
    func loadLocation(fromPlace place: Place) async{
        // Sets loading state, then attempts to load all data for an existing `Place` object.
        isLoading = true
        // Updates the place's `lastUsedAt` and saves the context upon success.
        do {
            place.lastUsedAt = .now
            //loading all data
            try await loadAll(for: place)
            
            // Catches and sets `appError` for any failure during the load process.
            
            try context.save()
            
        } catch {
            if let weatherError = error as? WeatherMapError {
                appError = weatherError
            } else {
                appError = .networkError(error)
            }
            print("Failed to load location from place: \(error)")
        }
        isLoading = false
    }
    
    private func revertToDefaultWithAlert(message: String) async {
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
        appError = .missingData(message: message)
        await loadDefaultLocation()
    }
    
    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        // Animates the map region to center on the given coordinate with a specified zoom level (span).
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
        )
        withAnimation{
            mapRegion = region
        }
    }
    
    private func loadAll(for place: Place) async throws {
        // Sets `activePlaceName` and prints a loading message.
        activePlaceName = place.name
        print("Loading data for place: \(place.name)")
        // Always refreshes weather data from the API.
        let weatherResponse = try await weatherService.fetchWeather(lat: place.latitude, lon: place.longitude)
        // Checks if the `Place` object has existing annotations (POIs).
        // If annotations are empty, fetches new POIs via `MKLocalSearch`, converts them to `AnnotationModel`s, adds them to the `Place`, saves the context, and sets `self.pois`.
        // If annotations exist, uses the cached list for `self.pois`.
        // Calls `focus(on:zoom:)` to update the map view.
        // Ensures the place is at the top of the `visited` list (if not already).
        
        //convert weather models
        currentWeather = Weather(from: weatherResponse.current)
        forecast = weatherResponse.daily.prefix(8).map{ Weather(from: $0) }
        
        //check if place has existing POIs
        if place.pois.isEmpty{
            print("No Cached POIs, fetching new ones...")
            let newPOIs = try await locationManager.findPOIs(lat: place.latitude, lon: place.longitude, limit: 5)
            //adding POIs to the place"s releationship
            
            for poi in newPOIs {
                poi.place = place
                place.pois.append(poi)
            }
            //save context to persist pois
            try context.save()
            
            //set pois for UI
            self.pois = place.pois
        } else {
            // POIs exist - use cached list
            print("Using cached POIs: \(place.pois.count) found")
            self.pois = place.pois
        }
        
        //update map region to center on the place
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        focus(on: coordinate, zoom: 0.02)
        
        //ensuring plcae is at the top of visited list
        if let index = visited.firstIndex(where: { $0.id == place.id }) {
            //moving to top if not
            if index != 0 {
                visited.remove(at: index)
                visited.insert(place, at: 0)
            } else {
                //plaec not in list adding to top
                visited.insert(place, at: 0)
            }
            print("✅ Successfully loaded all data for \(place.name)")
        }
        
        func delete(place: Place) {
            // Deletes the given `Place` object from the ModelContext and removes it from the `visited` array.
            // Attempts to save the context.
            context.delete(place)
            
            //remove from visited array
            visited.removeAll { $0.id == place.id }
            
            //save context
            do {
                try context.save()
            } catch {
                print("Failed to save after deletion: \(error)")
                appError = .missingData(message: "Failed to delete location")
            }
        }
        
        
        
        
        
        //api test
        //    func testWeatherService() async {
        //        print("🧪 Testing WeatherService...")
        //        isLoading = true
        //
        //        do {
        //            // Test with London coordinates
        //            let response = try await weatherService.fetchWeather(lat: 51.5074, lon: -0.1278)
        //
        //            print("✅ API Call Successful!")
        //            print("📍 Location: lat=\(response.lat), lon=\(response.lon)")
        //            print("🌡️ Current Temp: \(response.current.temp)K (≈\(response.current.temp - 273.15)°C)")
        //            print("☁️ Condition: \(response.current.weather.first?.main ?? "N/A")")
        //            print("📅 Daily Forecasts: \(response.daily.count) days")
        //
        //            // Test conversion to Weather model
        //            let currentWeather = Weather(from: response.current)
        //            print("✅ Weather Model Conversion: \(currentWeather.temperature)°C, \(currentWeather.condition)")
        //
        //            // Test daily forecast conversion
        //            if let firstDay = response.daily.first {
        //                let forecastWeather = Weather(from: firstDay)
        //                print("✅ Forecast Model: \(forecastWeather.temperature)°C, Min: \(forecastWeather.minTemp ?? 0)°C, Max: \(forecastWeather.maxTemp ?? 0)°C")
        //            }
        //
        //            print("🎉 All tests passed!")
        //
        //        } catch {
        //            print("❌ Test Failed: \(error)")
        //            if let weatherError = error as? WeatherMapError {
        //                appError = weatherError
        //            } else {
        //                appError = .networkError(error)
        //            }
        //        }
        //
        //           isLoading = false
        //       }
        
        //location manager test
        
        //    func testLocationManager() async {
        //        print("🧪 Testing LocationManager...")
        //        isLoading = true
        //
        //        do {
        //            // Test geocoding
        //            let result = try await locationManager.geocodeAddress("London")
        //            print("✅ Geocoding Success: \(result.name) at (\(result.lat), \(result.lon))")
        //
        //            // Test POI search
        //            let pois = try await locationManager.findPOIs(lat: result.lat, lon: result.lon, limit: 5)
        //            print("✅ Found \(pois.count) POIs:")
        //            for poi in pois {
        //                print("   - \(poi.name) at (\(poi.latitude), \(poi.longitude))")
        //            }
        //
        //            print("🎉 All LocationManager tests passed!")
        //
        //        } catch {
        //            print("❌ Test Failed: \(error)")
        //            appError = error as? WeatherMapError ?? .networkError(error)
        //        }
        //
        //        isLoading = false
        //    }
        
        
        
    }
}

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
    }

    func search() async throws {
        // If the query is not empty, calls `select(placeNamed:)` with the current query string.
    }

    /// Validate weather before saving a new place; create POI children once.
    func loadLocation(byName: String) async throws {
        // Sets loading state, then attempts to load data for the given place name.
        // 1. Checks if the place is already in `visited` and, if so, loads all data for the existing `Place` object, updates its `lastUsedAt`, and saves the context.
        // 2. Otherwise, geocodes the fresh place name using `locationManager`.
        // 3. Fetches weather data using `weatherService` as a fail-fast check.
        // 4. Finds Points of Interest (POIs) using `locationManager`, converts them to `AnnotationModel`s, and associates them with the new `Place`.
        // 5. Inserts the new `Place` into the `visited` array and saves the context.
        // 6. Updates UI by setting `pois`, `activePlaceName`, and focusing the map.
        // 7. If any step fails, logs the error and reverts to the default location with an alert.
    }

    func loadLocation(fromPlace place: Place) async{
        // Sets loading state, then attempts to load all data for an existing `Place` object.
        // Updates the place's `lastUsedAt` and saves the context upon success.
        // Catches and sets `appError` for any failure during the load process.
    }

    private func revertToDefaultWithAlert(message: String) async {
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
    }

    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        // Animates the map region to center on the given coordinate with a specified zoom level (span).
    }

    private func loadAll(for place: Place) async throws {
        // Sets `activePlaceName` and prints a loading message.
        // Always refreshes weather data from the API.
        // Checks if the `Place` object has existing annotations (POIs).
        // If annotations are empty, fetches new POIs via `MKLocalSearch`, converts them to `AnnotationModel`s, adds them to the `Place`, saves the context, and sets `self.pois`.
        // If annotations exist, uses the cached list for `self.pois`.
        // Calls `focus(on:zoom:)` to update the map view.
        // Ensures the place is at the top of the `visited` list (if not already).
    }

    func delete(place: Place) {
        // Deletes the given `Place` object from the ModelContext and removes it from the `visited` array.
        // Attempts to save the context.
    }

}

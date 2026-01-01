//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit


@MainActor
final class LocationManager {

    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
        // Uses `CLGeocoder` to convert a string address into geographic coordinates.
        let geocoder = CLGeocoder()
        
        // Extracts the name, latitude, and longitude from the first resulting placemark.
        // Throws a `WeatherMapError.geocodingFailed` if no valid location can be found.
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address){ placemarks, error in
                if let error = error {
                    continuation.resume(throwing: WeatherMapError.geocodingFailed(address))
                    return
                }
                //check if we have place marks
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    continuation.resume(throwing: WeatherMapError.geocodingFailed(address))
                    return
                }
                //extract name,latitude,longitude
                let name = placemark.name ?? placemark.locality ?? placemark.country ?? address
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                continuation.resume(returning: (name: name, lat: lat, lon: lon))
                
            }
        }
        // DUMMY RETURN TO SATISFY COMPILER
//        preconditionFailure("Stubbed function not implemented. Requires a (name: String, lat: Double, lon: Double) return.")
    }

    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {
        // Uses `MKLocalSearch` to find Points of Interest (POIs), specifically "Tourist Attractions," within a small region around the given latitude and longitude.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(
            center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) //~1km radius
        )
        // Executes the search request.
        let requset = MKLocalSearch.Request()
        requset.naturalLanguageQuery = "Tourist Attractions"
        requset.region = region
        requset.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: requset)
        do {
            let response = try await search.start()
            // Maps the `MKMapItem` results into an array of `AnnotationModel`s, filtering out any without a name.
            
            let pois = response.mapItems
                .compactMap { item -> AnnotationModel? in
                    //filter items without names
                    guard let name = item.name,
                          let location = item.placemark.location else {
                        return nil
                    }
                    //create annotation model
                    return AnnotationModel(
                        name: name, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude
                    )
                    
                }
            // Limits the final array size to the specified `limit`.
                .prefix(limit)
                .map{ $0 } //convert to array
            return Array(pois)
        } catch {
            //if search failed return an empty array.
            return []
        }
        
        // DUMMY RETURN TO SATISFY COMPILER
//        preconditionFailure("Stubbed function not implemented. Requires a [AnnotationModel] return.")
    }
}

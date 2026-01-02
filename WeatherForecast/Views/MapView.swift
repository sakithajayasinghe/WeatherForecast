////
////  MapView.swift
////  WeatherDashboardTemplate
////
////  Created by girish lukka on 18/10/2025.
////
//
//import SwiftUI
//import SwiftData
//
//struct MapView: View {
//    @EnvironmentObject var vm: MainAppViewModel
//
//    // MARK:  add other necessary variables
//    var body: some View {
//        VStack{
//            Text("Image shows the information to be presented in this view")
//            Spacer()
//            Image("map")
//                .resizable()
//
//
//            Spacer()
//        }
//        .frame(height: 600)
//
//    }
//}
//#Preview {
//    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
//    MapView()
//        .environmentObject(vm)
//}





//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @State private var selectedPOI: AnnotationModel?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Section: Interactive Map
            Map(coordinateRegion: $vm.mapRegion,
                annotationItems: vm.pois) { poi in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: poi.latitude,
                    longitude: poi.longitude
                )) {
                    VStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                            .onTapGesture {
                                // Tap map pin: zoom to 500m region
                                let coordinate = CLLocationCoordinate2D(
                                    latitude: poi.latitude,
                                    longitude: poi.longitude
                                )
                                vm.focus(on: coordinate, zoom: 0.005) // ~500m
                                selectedPOI = poi
                            }
                            .onLongPressGesture {
                                // Long-press: open Google search
                                openGoogleSearch(for: poi.name)
                            }
                        Text(poi.name)
                            .font(.caption2)
                            .padding(4)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                            .lineLimit(1)
                    }
                }
            }
            .frame(height: 400)
            
            // MARK: - Bottom Section: Scrollable POI List
            VStack(alignment: .leading, spacing: 12) {
                Text("Tourist Attractions")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(vm.pois) { poi in
                            POIListItemView(
                                poi: poi,
                                isSelected: selectedPOI?.id == poi.id
                            )
                            .onTapGesture {
                                // Tap list item: center map on that pin
                                let coordinate = CLLocationCoordinate2D(
                                    latitude: poi.latitude,
                                    longitude: poi.longitude
                                )
                                vm.focus(on: coordinate, zoom: 0.02)
                                selectedPOI = poi
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxHeight: 200)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.9),
                        Color.gray.opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            // Ensure map is focused on the current location when view appears
            if !vm.pois.isEmpty {
                let firstPOI = vm.pois[0]
                let coordinate = CLLocationCoordinate2D(
                    latitude: firstPOI.latitude,
                    longitude: firstPOI.longitude
                )
                vm.focus(on: coordinate, zoom: 0.02)
            }
        }
    }
    
    // Helper function to open Google search
    private func openGoogleSearch(for query: String) {
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(searchQuery)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - POI List Item View
struct POIListItemView: View {
    let poi: AnnotationModel
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Map Pin Icon
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.red)
            
            // POI Name
            Text(poi.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}

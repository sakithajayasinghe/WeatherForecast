////
////  VisitedPLacesView.swift
////  WeatherDashboardTemplate
////
////  Created by girish lukka on 18/10/2025.
////
//
//import SwiftUI
//import SwiftData
//
//
//struct VisitedPlacesView: View {
//    @EnvironmentObject var vm: MainAppViewModel
//    @Environment(\.modelContext) private var context // Not used in body, but kept for completeness
//
//    // MARK:  add local variables for this view
//
//    var body: some View {
//        VStack{
//            Text("Image shows the information to be presented in this view")
//            Spacer()
//            Image("places")
//                .resizable()
//
//            Spacer()
//        }
//        .frame(height: 600)
//    }
//}
//
//#Preview {
//    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
//    VisitedPlacesView()
//        .environmentObject(vm)
//}


//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData

struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.modelContext) private var context
    @State private var showLoadAlert = false
    @State private var loadedPlaceName = ""

    var body: some View {
        ZStack {
            backgroundGradient
            
            if vm.visited.isEmpty {
                emptyStateView
            } else {
                placesList
            }
        }
        .alert("Location Loaded", isPresented: $showLoadAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(loadedPlaceName) has been loaded")
        }
    }
    
    // MARK: - Computed Properties
    
    private var placesList: some View {
        List {
            ForEach(vm.visited) { place in
                placeRow(place: place)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No saved locations")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.secondary)
            Text("Search for a location to save it here")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }
    
    @ViewBuilder
    private func placeRow(place: Place) -> some View {
        let viewModel = vm // Capture vm explicitly
        VisitedPlaceRowView(place: place)
            .onTapGesture {
                handleTap(place: place)
            }
            .onLongPressGesture {
                openGoogleSearch(for: place.name)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.delete(place: place)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.2),
                Color.blue.opacity(0.15),
                Color.purple.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Helper Methods
    
    private func handleTap(place: Place) {
        Task { @MainActor in
            await vm.loadLocation(fromPlace: place)
            loadedPlaceName = place.name
            showLoadAlert = true
            vm.selectedTab = 0
        }
    }
    
    private func openGoogleSearch(for query: String) {
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(searchQuery)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Visited Place Row View
struct VisitedPlaceRowView: View {
    let place: Place
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(formatCoordinate(place.latitude)), \(formatCoordinate(place.longitude))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Last used: \(formatDate(place.lastUsedAt))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // Helper to format coordinates
    private func formatCoordinate(_ value: Double) -> String {
        String(format: "%.4f", value)
    }
    
    // Helper to format date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}

//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftData


import SwiftUI
import Charts   // Include if you plan to show a chart later

// MARK: - Temperature Category
/// Example of how to categorize temperatures for display.
/// Add more cases or adjust logic as needed.
enum TempCategory: String, CaseIterable {
    case cold = "Cold"   // Example category

    /// Choose a color to represent this category.
    var color: Color {
        switch self {
        case .cold:
            return .blue
            // TODO: add more cases (e.g., .cool, .warm, .hot) with colors as needed
        }
    }

    /// Convert a Celsius temperature into a category.
    static func from(tempC: Double) -> TempCategory {
        if tempC <= 0 {
            return .cold
        }
        // TODO: add more logic for other ranges (cool, warm, hot)
        return .cold
    }
}

// MARK: - Temperature Data Model
/// A single temperature reading for the chart or list.
private struct TempData: Identifiable {
    let id = UUID()
    let time: Date          // e.g., forecast date
    let type: String        // e.g., "High" or "Low"
    let value: Double       // numeric value
    let category: TempCategory
}

// MARK: - Forecast View
/// Stubbed Forecast View that includes an image placeholder to show
/// what the final view will look like. Replace the image once real data and charts are added.
struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel

    /// Converts forecast data into chart-friendly entries.
    private var chartData: [TempData] {
        vm.forecast.flatMap { day in
            [
                // These are hard-wired data, real data will come from weather data fetched by your api

                    TempData(
                        time: Date(),
                        type: "High",
                        value: 24.5,
                        category: .from(tempC: 24.5)
                    ),
                    TempData(
                        time: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                        type: "High",
                        value: 19.0,
                        category: .from(tempC: 19.0)
                    ),
                    TempData(
                        time: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        type: "High",
                        value: 5.5,
                        category: .from(tempC: 5.5)
                    )
                // TODO: add a "Low" entry or other data points if needed
            ]
        }
    }

    var body: some View {
        VStack {
            // MARK: - Header Text
            Text("Image shows the information to be presented in this view")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top)

            Spacer()

            // MARK: - Placeholder Image
            // Replace "forecast" with the name of your image asset.
            // You can add your actual design or a wireframe image in Assets.xcassets.
            Image("forecast")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()

            Spacer()
        }
        .frame(height: 600)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.indigo.opacity(0.1), .blue.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
        .navigationTitle("Forecast")
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}

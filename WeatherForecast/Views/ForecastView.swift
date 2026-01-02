//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

//import SwiftUI
//import Charts
//import SwiftData
//
//
//import SwiftUI
//import Charts   // Include if you plan to show a chart later

// MARK: - Temperature Category
/// Example of how to categorize temperatures for display.
/// Add more cases or adjust logic as needed.
//enum TempCategory: String, CaseIterable {
//    case cold = "Cold"   // Example category
//
//    /// Choose a color to represent this category.
//    var color: Color {
//        switch self {
//        case .cold:
//            return .blue
//            // TODO: add more cases (e.g., .cool, .warm, .hot) with colors as needed
//        }
//    }
//
//    /// Convert a Celsius temperature into a category.
//    static func from(tempC: Double) -> TempCategory {
//        if tempC <= 0 {
//            return .cold
//        }
//        // TODO: add more logic for other ranges (cool, warm, hot)
//        return .cold
//    }
//}
//
//// MARK: - Temperature Data Model
///// A single temperature reading for the chart or list.
//private struct TempData: Identifiable {
//    let id = UUID()
//    let time: Date          // e.g., forecast date
//    let type: String        // e.g., "High" or "Low"
//    let value: Double       // numeric value
//    let category: TempCategory
//}
//
//// MARK: - Forecast View
///// Stubbed Forecast View that includes an image placeholder to show
///// what the final view will look like. Replace the image once real data and charts are added.
//struct ForecastView: View {
//    @EnvironmentObject var vm: MainAppViewModel
//
//    /// Converts forecast data into chart-friendly entries.
//    private var chartData: [TempData] {
//        vm.forecast.flatMap { day in
//            [
//                // These are hard-wired data, real data will come from weather data fetched by your api
//
//                    TempData(
//                        time: Date(),
//                        type: "High",
//                        value: 24.5,
//                        category: .from(tempC: 24.5)
//                    ),
//                    TempData(
//                        time: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
//                        type: "High",
//                        value: 19.0,
//                        category: .from(tempC: 19.0)
//                    ),
//                    TempData(
//                        time: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
//                        type: "High",
//                        value: 5.5,
//                        category: .from(tempC: 5.5)
//                    )
//                // TODO: add a "Low" entry or other data points if needed
//            ]
//        }
//    }
//
//    var body: some View {
//        VStack {
//            // MARK: - Header Text
//            Text("Image shows the information to be presented in this view")
//                .font(.headline)
//                .multilineTextAlignment(.center)
//                .padding(.top)
//
//            Spacer()
//
//            // MARK: - Placeholder Image
//            // Replace "forecast" with the name of your image asset.
//            // You can add your actual design or a wireframe image in Assets.xcassets.
//            Image("forecast")
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: .infinity)
//                .cornerRadius(12)
//                .shadow(radius: 5)
//                .padding()
//
//            Spacer()
//        }
//        .frame(height: 600)
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [.indigo.opacity(0.1), .blue.opacity(0.05)]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//        )
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .padding()
//        .navigationTitle("Forecast")
//    }
//}
//
//#Preview {
//    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
//    ForecastView()
//        .environmentObject(vm)
//}






//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftData

// MARK: - Temperature Category
enum TempCategory: String, CaseIterable {
    case freezing = "Freezing"
    case cold = "Cold"
    case cool = "Cool"
    case mild = "Mild"
    case warm = "Warm"
    case hot = "Hot"

    /// Choose a color to represent this category.
    var color: Color {
        switch self {
        case .freezing: return .blue
        case .cold: return .cyan
        case .cool: return .teal
        case .mild: return .green
        case .warm: return .orange
        case .hot: return .red
        }
    }

    /// Convert a Celsius temperature into a category.
    static func from(tempC: Double) -> TempCategory {
        if tempC < 0 { return .freezing }
        else if tempC < 5 { return .cold }
        else if tempC < 15 { return .cool }
        else if tempC < 20 { return .mild }
        else if tempC < 28 { return .warm }
        else { return .hot }
    }
}

// MARK: - Temperature Data Model
private struct TempData: Identifiable {
    let id = UUID()
    let time: Date
    let type: String  // "High" or "Low"
    let value: Double
    let category: TempCategory
}

// MARK: - Forecast View
struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel

    /// Converts forecast data into chart-friendly entries (8 days, high and low)
    private var chartData: [TempData] {
        vm.forecast.prefix(8).flatMap { day in
            [
                TempData(
                    time: day.date,
                    type: "High",
                    value: day.maxTemp ?? day.temperature,
                    category: .from(tempC: day.maxTemp ?? day.temperature)
                ),
                TempData(
                    time: day.date,
                    type: "Low",
                    value: day.minTemp ?? day.temperature,
                    category: .from(tempC: day.minTemp ?? day.temperature)
                )
            ]
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Bar Chart Section (Top)
                if !vm.forecast.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("8-Day Forecast")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.horizontal)
                        
                        Chart(chartData) { data in
                            BarMark(
                                x: .value("Day", data.time, unit: .day),
                                y: .value("Temperature", data.value),
                                width: .ratio(0.3)
                            )
                            .foregroundStyle(data.category.color)
                            .position(by: .value("Type", data.type))
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let temp = value.as(Double.self) {
                                        Text("\(Int(temp))°")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .frame(height: 250)
                        .padding()
                    }
                    .padding(.top, 20)
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading forecast...")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 250)
                    .padding()
                }
                
                // MARK: - Forecast List Section (Bottom)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Details")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.horizontal)
                    
                    ForEach(vm.forecast.prefix(8)) { day in
                        ForecastRowView(day: day)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.indigo.opacity(0.2),
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Forecast Row View
struct ForecastRowView: View {
    let day: Weather
    
    var body: some View {
        HStack(spacing: 16) {
            // Day Name
            VStack(alignment: .leading, spacing: 4) {
                Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(
                    from: day.date.timeIntervalSince1970
                ))
                    .font(.system(size: 16, weight: .semibold))
                
                Text(day.description.capitalized)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            // Weather Icon
            Image(systemName: weatherIcon(for: day.condition))
                .font(.system(size: 24))
                .foregroundColor(TempCategory.from(tempC: day.temperature).color)
                .frame(width: 40)
            
            // Temperature Range
            HStack(spacing: 8) {
                if let maxTemp = day.maxTemp, let minTemp = day.minTemp {
                    Text("\(Int(maxTemp.rounded()))°")
                        .font(.system(size: 18, weight: .semibold))
                    Text("/")
                        .foregroundColor(.secondary)
                    Text("\(Int(minTemp.rounded()))°")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.secondary)
                } else {
                    Text("\(Int(day.temperature.rounded()))°")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.3))
        )
        .padding(.horizontal)
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear": return "sun.max.fill"
        case "clouds": return "cloud.fill"
        case "rain": return "cloud.rain.fill"
        case "drizzle": return "cloud.drizzle.fill"
        case "thunderstorm": return "cloud.bolt.fill"
        case "snow": return "cloud.snow.fill"
        case "mist", "fog", "haze": return "cloud.fog.fill"
        default: return "cloud.sun.fill"
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}

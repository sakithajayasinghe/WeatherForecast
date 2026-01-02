//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

//import SwiftUI
//import SwiftData
//
//
//struct CurrentWeatherView: View {
//    @EnvironmentObject var vm: MainAppViewModel
//
//    var body: some View {
//        VStack{
//            Text("Image shows the information to be presented in this view")
//            Spacer()
//            Image("now")
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
//    CurrentWeatherView()
//        .environmentObject(vm)
//}



import SwiftUI
import SwiftData

struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Location Name and Date
                VStack(spacing: 8) {
                    Text(vm.activePlaceName.isEmpty ? "Loading..." : vm.activePlaceName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let weather = vm.currentWeather {
                        Text(DateFormatterUtils.formattedDateTime(from: weather.date.timeIntervalSince1970))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // Weather Icon and Temperature
                if let weather = vm.currentWeather {
                    VStack(spacing: 16) {
                        // Weather Icon (using SF Symbols based on condition)
                        Image(systemName: weatherIcon(for: weather.condition))
                            .font(.system(size: 80))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.multicolor)
                        
                        // Temperature
                        HStack(alignment: .top, spacing: 4) {
                            Text("\(Int(weather.temperature.rounded()))")
                                .font(.system(size: 72, weight: .thin))
                            Text("°C")
                                .font(.system(size: 32, weight: .light))
                                .padding(.top, 8)
                        }
                        .foregroundColor(.primary)
                        // Condition Description
                        Text(weather.description.capitalized)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    // Key Weather Metrics
                    HStack(spacing: 30) {
                        WeatherMetricView(
                            icon: "humidity",
                            value: "\(weather.humidity)%",
                            label: "Humidity"
                        )
                        
                        WeatherMetricView(
                            icon: "wind",
                            value: String(format: "%.1f", weather.windSpeed),
                            label: "Wind"
                        )
                        WeatherMetricView(
                            icon: "barometer",
                            value: "\(weather.pressure)",
                            label: "Pressure"
                        )
                    }
                    .padding(.vertical, 20)
                    
                    // Feels Like
                    Text("Feels like \(Int(weather.feelsLike.rounded()))°C")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.secondary)
                    
                    // Advisory Message
                    let advice = WeatherAdviceCategory.from(
                        temp: weather.temperature,
                        description: weather.description
                    )
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: advice.icon)
                                .font(.system(size: 24))
                                .foregroundColor(advice.color)
                            Text(advice.adviceText)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(advice.color.opacity(0.1))
                        )
                    }
                    .padding(.top, 20)
                } else {
                    // Loading or No Data State
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading weather data...")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 100)
                }
            }
            .padding()
        }
         .background(
             LinearGradient(
                 gradient: Gradient(colors: [
                     Color.blue.opacity(0.3),
                     Color.purple.opacity(0.2),
                     Color.pink.opacity(0.1)
                 ]),
                 startPoint: .topLeading,
                 endPoint: .bottomTrailing
             )
         )
     }
     
     // Helper function to map weather condition to SF Symbol
     private func weatherIcon(for condition: String) -> String {
         switch condition.lowercased() {
         case "clear":
             return "sun.max.fill"
         case "clouds":
             return "cloud.fill"
         case "rain":
             return "cloud.rain.fill"
         case "drizzle":
             return "cloud.drizzle.fill"
          case "thunderstorm":
              return "cloud.bolt.fill"
          case "snow":
              return "cloud.snow.fill"
          case "mist", "fog", "haze":
              return "cloud.fog.fill"
          default:
              return "cloud.sun.fill"
          }
      }
  }

  // Helper view for weather metrics
  struct WeatherMetricView: View {
      let icon: String
      let value: String
      let label: String
      var body: some View {
          VStack(spacing: 8) {
              Image(systemName: icon)
                  .font(.system(size: 24))
                  .foregroundColor(.blue)
              Text(value)
                  .font(.system(size: 18, weight: .semibold))
              Text(label)
                  .font(.system(size: 12))
                  .foregroundColor(.secondary)
          }
      }
  }

  #Preview {
      let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
      CurrentWeatherView()
          .environmentObject(vm)
  }

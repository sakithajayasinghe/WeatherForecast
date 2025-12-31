//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel

    var body: some View {
        VStack{
            Text("Image shows the information to be presented in this view")
            Spacer()
            Image("now")
                .resizable()

            Spacer()
        }
        .frame(height: 600)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    CurrentWeatherView()
        .environmentObject(vm)
}

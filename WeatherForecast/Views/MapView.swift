//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel

    // MARK:  add other necessary variables
    var body: some View {
        VStack{
            Text("Image shows the information to be presented in this view")
            Spacer()
            Image("map")
                .resizable()


            Spacer()
        }
        .frame(height: 600)

    }
}
#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}

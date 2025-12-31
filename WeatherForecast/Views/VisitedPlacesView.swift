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
    @Environment(\.modelContext) private var context // Not used in body, but kept for completeness

    // MARK:  add local variables for this view

    var body: some View {
        VStack{
            Text("Image shows the information to be presented in this view")
            Spacer()
            Image("places")
                .resizable()

            Spacer()
        }
        .frame(height: 600)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}

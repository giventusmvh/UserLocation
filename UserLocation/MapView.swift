//
//  ContentView.swift
//  UserLocation
//
//  Created by Giventus Marco Victorio Handojo on 10/08/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject private var viewModel = MapViewViewModel()
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                .onAppear{
                    viewModel.checkIfLocationServicesIsEnabled()
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MapView()
}


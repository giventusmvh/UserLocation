//
//  MapViewViewModel.swift
//  UserLocation
//
//  Created by Giventus Marco Victorio Handojo on 10/08/24.
//

import Foundation
import MapKit

enum MapDetails {
    static let startingPosition = CLLocationCoordinate2D(latitude: -6.302062993687138, longitude: 106.65229908106305 )
    static let spanCoordinate = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

final class MapViewViewModel: NSObject ,ObservableObject, CLLocationManagerDelegate{
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(center: MapDetails.startingPosition , span: MapDetails.spanCoordinate)
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            // locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        }else{
            print("Error, harusnya kasih alert sih")
        }
    }
    
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location restricted")
        case .denied:
            print("location denied ")
        case .authorizedAlways , .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate , span: MapDetails.spanCoordinate)
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

//
//  MapViewViewModel.swift
//  UserLocation
//
//  Created by Giventus Marco Victorio Handojo on 10/08/24.
//

import FirebaseFirestore
import FirebaseCore
import Foundation
import MapKit

enum MapDetails {
    static let startingPosition = CLLocationCoordinate2D(latitude: -6.302062993687138, longitude: 106.65229908106305 )
    static let spanCoordinate = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

final class MapViewViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var timer: Timer?
    private var db = Firestore.firestore() // Firestore instance
    private let deviceUUID: String

    @Published var region = MKCoordinateRegion(center: MapDetails.startingPosition, span: MapDetails.spanCoordinate)

    override init() {
        // Generate or retrieve the device's unique identifier
        if let uuid = UserDefaults.standard.string(forKey: "deviceUUID") {
            deviceUUID = uuid
        } else {
            deviceUUID = UUID().uuidString
            UserDefaults.standard.set(deviceUUID, forKey: "deviceUUID")
        }

        super.init()
        
        checkIfLocationServicesIsEnabled()

//        locationManager = CLLocationManager()
//        locationManager?.delegate = self
//        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager?.allowsBackgroundLocationUpdates = true
//        locationManager?.pausesLocationUpdatesAutomatically = false
//        locationManager?.requestAlwaysAuthorization()
    }

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Error, harusnya kasih alert sih")
        }
    }

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location restricted")
        case .denied:
            print("Location denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MapDetails.spanCoordinate)
            startLocationTimer() // Start the timer when authorization is granted
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func startLocationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.saveCurrentLocationToFirebase()
        }
    }

    func stopLocationTimer() {
        timer?.invalidate()
        timer = nil
    }

    func saveCurrentLocationToFirebase() {
        guard let location = locationManager?.location else {
            print("Location is not available")
            return
        }
        
        // Prepare the data to save
        let coordinates = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date())
        ] as [String : Any]
        
        // Use the device's UUID as the document ID
        let documentRef = db.collection("locations").document(deviceUUID)
        
        // Use setData to update the document with the new coordinates
        documentRef.setData(coordinates) { error in
            if let error = error {
                print("Error saving location to Firebase: \(error.localizedDescription)")
            } else {
                print("Location updated successfully!")
                print(location.coordinate)
            }
        }
    }

    deinit {
        stopLocationTimer() // Stop the timer when the ViewModel is deallocated
    }
}

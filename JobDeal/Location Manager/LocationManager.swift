//
//  File.swift
//  JobDeal
//
//  Created by Priba on 1/9/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol LocationDelegate: class {
    func didUpdateLocations(newLocation: CLLocation)
}


class LocationManager: NSObject, CLLocationManagerDelegate{
    static let sharedInstance = LocationManager()
    weak var delegate: LocationDelegate?
    let manager: CLLocationManager = CLLocationManager()
    
    func startUpdatingAccuratLocation() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdatingHundredMetersLocation() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        DataManager.sharedInstance.userLastLocation = mostRecentLocation.coordinate
        delegate?.didUpdateLocations(newLocation: mostRecentLocation)
    }
}

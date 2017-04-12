//
//  LocationService.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-12.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//


import Foundation
import CoreLocation

class LocationService : NSObject, CLLocationManagerDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    let locationManager = CLLocationManager()
    var userLocation : CLLocation?
    
    override init(){
        super.init()
        locationManager.delegate = self
    }
    // Attempt to retrieve the user's location after they have logged in / signed up
    // Calling this function will begin the process.
    func attemptUserLocationUpdate(){
        
        isAuthorizedtoGetUserLocation()
        if let locationHasBeenUpdated : Bool = userDefaults.object(forKey: Constants.USER_DEFAULTS.userLocationSaved) as? Bool {
            if(!locationHasBeenUpdated && CLLocationManager.locationServicesEnabled()){
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        } else {
            if(CLLocationManager.locationServicesEnabled()){
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse  {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
        }
    }
    
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(locations.count > 0){
            userLocation = locations[0]
        }
        if(userLocation != nil){
            locationManager.stopUpdatingLocation()
            CLGeocoder().reverseGeocodeLocation(userLocation!) { (placemark, error) in
                if (error != nil) {
                    print(error.debugDescription)
                }
                
                if (placemark?.count)! > 0 {
                    let placemarkInfo = placemark?[0]
                    self.buildAndSaveLocationObject(placemark: placemarkInfo!)
                }
            }
        }
        
    }
    
    func buildAndSaveLocationObject(placemark : CLPlacemark){
        var location : [String : AnyObject] = [:]
        location["country"] = placemark.country as AnyObject?
        location["city"] = placemark.addressDictionary?["City"] as AnyObject?
        location["address"] = placemark.addressDictionary?["Street"] as AnyObject?
        location["province"] = placemark.addressDictionary?["State"] as AnyObject?
        location["latitude"] = placemark.location?.coordinate.latitude as AnyObject?
        location["longitude"] = placemark.location?.coordinate.longitude as AnyObject?
        
        UserService().updateUserLocation(location: location) { (dictionary) in
            print("Finished updating location")
            print(dictionary)
            self.userDefaults.set(true, forKey: Constants.USER_DEFAULTS.userLocationSaved)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }

    
}

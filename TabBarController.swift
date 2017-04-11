//
//  TabBarController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import CoreLocation

class TabBarController: UITabBarController, UITabBarControllerDelegate, CLLocationManagerDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    let locationManager = CLLocationManager()
    var userLocation : CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.selectedViewController = self.viewControllers?[0]
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool){
        locationManager.delegate = self
        
        isAuthorizedtoGetUserLocation()
        if let locationHasBeenUpdated : Bool = userDefaults.object(forKey: Constants.USER_DEFAULTS.userLocationSaved) as? Bool {
            if(!locationHasBeenUpdated && CLLocationManager.locationServicesEnabled()){
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if(viewController.restorationIdentifier == "profileNavigationController"){
            let profileNavController = viewController as! UINavigationController
            let profileView : ProfileViewController = profileNavController.viewControllers[0] as! ProfileViewController
            profileView.isCurrentUsersProfile = true
            self.getUserProfile(profileView: profileView)
        }
        
        if (viewController.restorationIdentifier == "messageNavigationController"){
            let messageNavController = viewController as! UINavigationController
            let messageView : MessagesViewController = messageNavController.viewControllers[0] as! MessagesViewController
            messageView.loadRecipientConversations()
        }
        
        if (viewController.restorationIdentifier == "searchNavigationController"){
            let searchNavController = viewController as! UINavigationController
            let searchView : SearchViewController = searchNavController.viewControllers[0] as! SearchViewController
            searchView.getMostRecentBooks()
        }

    }
    
    // Get the current user's profile
    func getUserProfile(profileView : ProfileViewController){
        UserService().getUserProfile(userId: nil) { (dictionary) in
            self.userDefaults.set(dictionary["name"], forKey: Constants.USER_DEFAULTS.nameKey)
            self.userDefaults.set(dictionary["email"], forKey: Constants.USER_DEFAULTS.emailKey)
            self.userDefaults.set(dictionary["pushNotification"], forKey: Constants.USER_DEFAULTS.notificationKey)
            let userId : Int = dictionary["id"] as! Int
            profileView.loadUserAvailableBooks(userId: String(userId))
            profileView.userId = String(userId)
            if let avatarUrl : String = dictionary["avatar"] as? String{
                self.userDefaults.set(avatarUrl, forKey: Constants.USER_DEFAULTS.userAvatar)
            }
            
            if let bio : String = dictionary["bio"] as? String {
                self.userDefaults.set(bio, forKey: Constants.USER_DEFAULTS.bioKey)
            }
        }
    }
    
    func setAvatarImage(imageUrl: String, imageView : UIImageView){
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL){
                if let imageUrl = UIImage(data: data as Data) {
                    imageView.image = imageUrl
                }
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

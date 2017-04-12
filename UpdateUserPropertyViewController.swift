//
//  UpdateUserPropertyViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-06.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import MapKit

class UpdateUserPropertyViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    var navItemHeader : String?
    var placeHolderText : String?
    var textFieldData : String?
    var currentlyUpdating : String?
    var searchBar:UISearchBar = UISearchBar()
    let locationManager = CLLocationManager()
    var userLocation : CLLocation?
    var mapView: MKMapView!
    var placeMarkInfo : CLPlacemark?
    var annotations : [MKPointAnnotation] = []
    let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
    let currentPassword = UITextField()
    let newPassword = UITextField()
    let confirmPassword = UITextField()

    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var bioTextView: UITextView!
    @IBOutlet var saveUpdateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchBarStyle = UISearchBarStyle.default
        searchBar.prompt = "Search for your location..."
        searchBar.showsCancelButton = true
        mapView = MKMapView()
        mapView.mapType = .standard
        mapView.frame = self.view.frame
        mapView.delegate = self
        searchBar.delegate = self
        locationManager.delegate = self
        if(navItemHeader != nil){
            self.navigationItem.title = navItemHeader!
        }
        self.setValues()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserProperty(){
        print("Updating!")
        //TODO: reset the user value for user defaults
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchBarText = self.searchBar.text
        if(searchBarText == nil){
            return
        }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            if(response.mapItems.count > 0){
                let annotation : MKPointAnnotation = self.buildAnnotationFromMapItems(mapItem: response.mapItems[0])
                if(self.annotations.count > 0){
                    self.mapView.removeAnnotations(self.annotations)
                    self.annotations.removeAll()
                }
                self.mapView.addAnnotation(annotation)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude)), self.span)
                self.mapView.setRegion(region, animated: true)
                self.annotations.append(annotation)
            }
            
        }

    }
    
    func buildAnnotationFromMapItems(mapItem : MKMapItem) -> MKPointAnnotation{
        placeMarkInfo = mapItem.placemark
        let latitude = placeMarkInfo?.location?.coordinate.latitude
        let longitude = placeMarkInfo?.location?.coordinate.longitude
        let annotation : MKPointAnnotation = MKPointAnnotation()
        if(latitude != nil && longitude != nil){
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            return annotation
        }
        return annotation
    }
    
    func setValues(){
        self.mapView.isHidden = true
        self.searchBar.isHidden = true
        if(currentlyUpdating == "Name"){
            if(textFieldData != nil){
                nameTextField.text = textFieldData!
            }
            self.nameTextField.isHidden = false
        }
        
        if(currentlyUpdating == "Bio"){
            if(textFieldData != nil || (textFieldData?.characters.count)! > 0){
                bioTextView.text = textFieldData!
            }
            self.bioTextView.isHidden = false
        }
        
        if(currentlyUpdating == "Location"){
            self.mapView.isHidden = false
            self.searchBar.frame = CGRect(x: 0, y: 0, width: 300, height: 80)
            self.searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 100)
            self.searchBar.isHidden = false
            self.view.addSubview(self.mapView)
            self.view.addSubview(self.searchBar)
            self.view.bringSubview(toFront: self.searchBar)
            self.view.bringSubview(toFront: self.saveUpdateButton)
          
            isAuthorizedtoGetUserLocation()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
        
        if(currentlyUpdating == "Password"){
            var passwordTextfields : [UITextField] = []
            currentPassword.placeholder = "Current Password"
            newPassword.placeholder = "New Password"
            confirmPassword.placeholder = "Confirm Password"
            passwordTextfields.append(currentPassword)
            passwordTextfields.append(newPassword)
            passwordTextfields.append(confirmPassword)
            self.drawPasswordTextFields(textFields: passwordTextfields)
        }
    }
    
    func drawPasswordTextFields(textFields : [UITextField]){
        for (index,tf) in textFields.enumerated() {
            let textViewHeightOffset = 60
            let offsetHeight = textViewHeightOffset * (index + 1)
            print(self.view.bounds.midX)
            tf.frame = CGRect(x: 0, y: offsetHeight, width: Int(self.view.bounds.width * 0.75), height: 45)
            tf.center.x = view.center.x
            tf.backgroundColor = UIColor.blue
            self.view.addSubview(tf)
        }
    }
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse  {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        if(currentlyUpdating == "Name"){
            self.verifyUpdateName()
        }
        
        if(currentlyUpdating == "Bio"){
            self.verifyAndUpdateBio()
        }
        
        if(currentlyUpdating == "Location" && placeMarkInfo != nil){
            self.buildAndSaveLocationObject(placemark: placeMarkInfo!)
        }
        
        if(currentlyUpdating == "Password"){
            self.saveNewPassword()
        }
    }
    
    private func showInvalidAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Check that email input is provided
    func validateText(text : String) -> Bool{
        if(text.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"Name cannot be empty.")
            return false
        }
        return true
    }
    
    func validateBio(text : String) -> Bool{
        if(text.characters.count > 140){
            self.showInvalidAlert(alertTitle: "Error", alertMessage: "Maximum 140 characters can be used for your bio.")
            return false
        }
        
        return true
    }
    
    func verifyAndUpdateBio(){
        let updatedBio : String = bioTextView.text!
        if(validateBio(text: updatedBio) == true){
            UserService().updateUserBio(bio: updatedBio, completed: { (dictionary) in
                let newBio : String = dictionary["bio"] as! String
                if(newBio == updatedBio){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.profileUpdated), object: nil) // notify that profile has been updated
                    print("Success")
                }
            })
        }
      }
    
    func verifyUpdateName(){
        let updatedName : String = nameTextField.text!
        if(validateText(text: updatedName) == true){
            UserService().updateUserName(name: updatedName, completed: { (dictionary) in
                let newName : String = dictionary["name"] as! String
                if(newName == updatedName){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.profileUpdated), object: nil) // notify that profile has been updated
                    print("Success")
                }
            })
        }
    }
    
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.count > 0){
            userLocation = locations[0]
        }
        if(userLocation != nil){
            if(annotations.count > 0){
                self.mapView.removeAnnotations(annotations)
                self.annotations.removeAll()
            }
            let annotation : MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!)
            self.mapView.addAnnotation(annotation)
            annotations.append(annotation)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude)), span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
            CLGeocoder().reverseGeocodeLocation(userLocation!) { (placemark, error) in
                if (error != nil) {
                    print(error.debugDescription)
                }
                
                if (placemark?.count)! > 0 {
                    self.placeMarkInfo = placemark?[0]
                }
            }
        }
        
    }
    
    func buildAndSaveLocationObject(placemark : CLPlacemark){
        var location : [String : AnyObject] = [:]
        location["country"] = placemark.country as AnyObject?
        location["city"] = placemark.addressDictionary?["City"] as AnyObject?
        if let address : AnyObject = placemark.addressDictionary?["Street"] as AnyObject? {
            location["address"] = address
        }
        location["province"] = placemark.addressDictionary?["State"] as AnyObject?
        location["latitude"] = placemark.location?.coordinate.latitude as AnyObject?
        location["longitude"] = placemark.location?.coordinate.longitude as AnyObject?
        
        UserService().updateUserLocation(location: location) { (dictionary) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.profileUpdated), object: nil) // notify that profile has been updated
            print("Success")
        }
    }
    
    func saveNewPassword(){
        if(validatePasswordTextFields()){
            let data : [String : AnyObject] = [
                "oldPassword" : currentPassword.text as AnyObject,
                "newPassword" : newPassword.text as AnyObject,
                "confirmPassword" : confirmPassword.text as AnyObject
            ]
            
            UserService().updateUserPassword(data: data, completed: { (dictionary) in
                print(dictionary)
                let operationType : String = dictionary.value(forKey: "operationType") as! String
                if(operationType == "UPDATE"){
                    let oauthToken : [String : AnyObject] = dictionary["token"] as! [String : AnyObject]
                    let accessToken = "Bearer ".appending(oauthToken["access_token"] as! String)
                    self.userDefaults.set(accessToken, forKey: "access_token")  // update the token
                }
            })
            
        }
    }
    
    func validatePasswordTextFields() -> Bool{
        if((currentPassword.text?.characters.count)! <= 0){
            return false
        }
        if((newPassword.text?.characters.count)! < 6){
            //todo: show alert
            return false
        }
        
        if(newPassword.text != confirmPassword.text){
            // todo: show alert
            return false
        }
        
        return true
        
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if (annotation is MKUserLocation) {
//            print("I am the user's location!")
//        }
//        return annotation
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

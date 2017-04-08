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
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        if(locations.count > 0){
            userLocation = locations[0]
            let region:MKCoordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!), span)
            mapView.setRegion(region, animated: true)
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

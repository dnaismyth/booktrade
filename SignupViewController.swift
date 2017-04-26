//
//  SignupViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-12.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    typealias FinishedStoringResponse = () -> ()
        
    let userDefaults = Foundation.UserDefaults.standard
    
    @IBOutlet var exitButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signupButton: UIButton!
    
    let locService = LocationService()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        nameTextField.designTextField(iconName: "name", tintColor: UIColor.black, placeholder: "Name")
        emailTextField.designTextField(iconName: "email", tintColor: UIColor.black, placeholder: "Email")
        passwordTextField.designTextField(iconName: "password", tintColor: UIColor.black, placeholder: "Password")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        let signupRequest : [String : AnyObject] = self.buildDataForSignupRequest()
        UserService().signupNewUser(signupRequest: signupRequest) { (dictionary) in
            if let response : [String:AnyObject] = dictionary["data"] as? [String:AnyObject]{
                if(response["access_token"] != nil){
                    self.storeDefaultSearchFilter()
                    UserService().storeLoginResponse(response: response as NSDictionary, completed: {
                        if let fcmToken = self.userDefaults.string(forKey: Constants.USER_DEFAULTS.fcmDeviceToken) {
                            UserService().storeUserPlatformToken(deviceToken: fcmToken)
                        }
                        self.locService.attemptUserLocationUpdate()
                        UserService().getUserProfileAndStoreUserDefaults(completed: {
                            if let token = self.userDefaults.string(forKey: Constants.USER_DEFAULTS.firebaseDBToken){
                                FirebaseService().authenticateUser(customToken: token)
                            }
                        })
                    })
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"tabBarController") as! TabBarController
                    let searchNavController = viewController.viewControllers?[0] as! UINavigationController
                    let searchController = searchNavController.viewControllers[0] as! SearchViewController
                    searchController.getMostRecentBooks()   // load the most recent books before entering view
                    self.present(viewController, animated: true)
                } else {
                    self.showInvalidAlert(alertTitle: "Error Signing Up", alertMessage: "The e-mail address is already in use.")
                }
            } else {
                self.showInvalidAlert(alertTitle: "Error Signing Up", alertMessage: "An issue occured when trying to sign up.")
            }

        }
    }
    
    // Check that email input is provided
    func validateEmail() -> String {
        let email: String! = self.emailTextField.text
        if(email.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"You must provide en e-mail address.")
        }
        return email;
    }
    
    // Validate that a name has been provided
    func validateName() -> String {
        let name : String! = self.nameTextField.text
        if(name.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"You must provide a name.")
        }
        return name;
    }
    
    // Check that password input is provided
    func validatePassword() -> String {
        let password: String! = self.passwordTextField.text
        if(password.characters.count < 5){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"Password must be a minimum of 6 characters.")
        }
        return password;
    }
    
    private func buildDataForSignupRequest() -> [String : AnyObject] {
        let name : String = self.validateName()
        let email : String = self.validateEmail()
        let password : String = self.validatePassword()
        let signupRequest : [String : AnyObject] = [
            "name" : name as AnyObject,
            "email" : email as AnyObject,
            "password" : password as AnyObject
        ]
        
        return signupRequest
        
    }
    
    private func storeDefaultSearchFilter(){
        let filter_pref : [String : AnyObject] = Constants.FILTER.defaultFilter
        userDefaults.set( filter_pref, forKey: "filter_pref")
    }

    private func showInvalidAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

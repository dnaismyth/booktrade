//
//  LoginViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let userDefaults = Foundation.UserDefaults.standard
    typealias FinishedStoringResponse = () -> ()
    
    let locService = LocationService()
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.borderColor = UIColor.white.cgColor
        self.loginButton.cornerRadius()
        self.logoImageView.renderImageColor(color: UIColor.white)
        emailTextField.designTextField(iconName: "email", tintColor: UIColor.white, placeholder: "Email")
        passwordTextField.designTextField(iconName: "password", tintColor: UIColor.white, placeholder: "Password")
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check that email input is provided
    func validateEmail() -> String {
        let email: String! = self.emailTextField.text
        if(email.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"Please enter valid credentials.")
        }
        return email;
    }
    
    // Check that password input is provided
    func validatePassword() -> String {
        let password: String! = self.passwordTextField.text
        if(password.characters.count <= 0){
            self.showInvalidAlert(alertTitle:"Error", alertMessage:"Please enter valid credentials.")
        }
        return password;
    }
    
    private func showInvalidAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func userLogin(_ sender: UIButton) {
        let email = validateEmail()
        let password = validatePassword()
        let form = "username=".appending(email).appending("&password=").appending(password).appending("&grant_type=password")
        PostRequest().urlencodedPost(postUrl: Constants.API.login, form: form, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                if(dictionary["access_token"] != nil){
                    self.storeDefaultSearchFilter() // store the default search filter into user preferences
                    UserService().storeLoginResponse(response: dictionary, completed: {
                        if let fcmToken = self.userDefaults.string(forKey: Constants.USER_DEFAULTS.fcmDeviceToken) {
                            UserService().storeUserPlatformToken(deviceToken: fcmToken)
                        }
                        self.locService.attemptUserLocationUpdate()
                        UserService().getUserProfileAndStoreUserDefaults(completed: {
                            if let firebaseToken = self.userDefaults.string(forKey: Constants.USER_DEFAULTS.firebaseDBToken){
                                FirebaseService().authenticateUser(customToken: firebaseToken)
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
                    self.showInvalidAlert(alertTitle: "Error Signing In", alertMessage: "The e-mail or password is incorrect.")
                }
            }
        })
    }
    
    private func storeDefaultSearchFilter(){
        let filter_pref : [String : AnyObject] = Constants.FILTER.defaultFilter
        userDefaults.set( filter_pref, forKey: "filter_pref")
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

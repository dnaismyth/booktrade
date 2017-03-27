//
//  LoginViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let userDefaults = Foundation.UserDefaults.standard

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
                    self.storeLoginResponse(response: dictionary)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"tabBarController")
                    self.present(viewController, animated: true)
                } else {
                    self.showInvalidAlert(alertTitle: "Error Signing In", alertMessage: "The e-mail or password is incorrect.")
                }
            }
        })
    }
    
    private func storeLoginResponse(response : NSDictionary){
        let access_token = "Bearer ".appending(response["access_token"] as! String)
        let refresh_token = response["refresh_token"] as! String
        let expires_in = response["expires_in"]
        userDefaults.set( access_token , forKey: "access_token")
        userDefaults.set( refresh_token, forKey: "refresh_token")
        userDefaults.set( expires_in, forKey:"expires_in")
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

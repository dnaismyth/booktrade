//
//  SettingsTableViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-06.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    @IBOutlet var pushNotification: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        pushNotification.isOn = userDefaults.bool(forKey: Constants.USER_DEFAULTS.notificationKey)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)

        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "updateProfileSegue", sender: self)
            print("I'm selected")
        }
        
        if(cell?.reuseIdentifier == "logOutCell"){
            self.logoutCurrentUser()
        }
        
        
    }
    
    private func logoutCurrentUser(){
        UserService().logout { (dictionary) in
            print(dictionary)
            let loginVC: LoginViewController? = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController
            self.present(loginVC!, animated: true, completion: nil)
        }
    }
    
    // Toggle on and off user's push notification preference
    @IBAction func pushNotificationToggle(_ sender: UISwitch) {
        if(sender.isOn){
            self.updateNotification(notification: true)
        } else {
            self.updateNotification(notification: false)
        }
    }
    
    private func updateNotification(notification : Bool){
        UserService().updatePushNotificationSettings(pushNotification: notification) { (dictionary) in
            if(dictionary["pushNotification"] as! Bool == true){
                self.pushNotification.isOn = true
            } else {
                self.pushNotification.isOn = false
            }
        }
    }
    
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

}

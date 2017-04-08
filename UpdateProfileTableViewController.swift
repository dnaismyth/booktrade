//
//  UpdateProfileTableViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-06.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class UpdateProfileTableViewController: UITableViewController {
    
    let userDefaults = Foundation.UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "updateNameSegue"){
            let propertyVC = segue.destination as! UpdateUserPropertyViewController
            propertyVC.currentlyUpdating = "Name"
            propertyVC.navItemHeader = "Update Name"
            propertyVC.placeHolderText = "Name"
            let name : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.nameKey)!
            propertyVC.textFieldData = name
        }
        
        if(segue.identifier == "updateAboutSegue"){
            let propertyVC = segue.destination as! UpdateUserPropertyViewController
            propertyVC.currentlyUpdating = "Bio"
            propertyVC.navItemHeader = "Update About Me"
            propertyVC.placeHolderText = "About Me"
            if let bio : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.bioKey){
                propertyVC.textFieldData = bio
            } else {
                propertyVC.textFieldData = "Update About Me..."
            }
        }
        
        if(segue.identifier == "updateLocationSegue"){
            let propertyVC = segue.destination as! UpdateUserPropertyViewController
            propertyVC.currentlyUpdating = "Location"
            propertyVC.navItemHeader = "Update Location"
        }
    }
 

}

//
//  UpdateProfileTableViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-06.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class UpdateProfileTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var aboutLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.emailLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.emailKey)
        let avatarUrl : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userAvatar)!
        self.setAvatarImage(imageUrl: avatarUrl, imageView: self.avatarImage)
        locationLabel.text = Utilities.buildLocationLabel(location: userDefaults.dictionary(forKey: Constants.USER_DEFAULTS.locationKey) as! [String : AnyObject])
        aboutLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.bioKey)
        nameLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.nameKey)
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
        
        if segue.identifier == "settingsChangeAvatarSegue" {
            let popupMenu = segue.destination as! ChangeAvatarViewController
            popupMenu.segueFromController = "SettingsController"
            popupMenu.modalPresentationStyle = UIModalPresentationStyle.popover
            let controller = popupMenu.popoverPresentationController
            if controller != nil {
                controller?.delegate = self
                controller?.sourceView = self.view
                controller?.sourceRect = CGRect(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.maxY, width: 0, height: 0)
                controller?.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5)
                //controller?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
 
    @IBAction func changeAvatarButton(_ sender: UIButton) {
        
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        if let changeAvatarView = segue.source as? ChangeAvatarViewController {
            self.avatarImage.image = changeAvatarView.imageView.image
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

}

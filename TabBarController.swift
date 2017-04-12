//
//  TabBarController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.selectedViewController = self.viewControllers?[0]
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool){
       
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
}

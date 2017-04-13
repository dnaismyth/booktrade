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
            self.setUpUserProfile(profileView: profileView)
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
    func setUpUserProfile(profileView : ProfileViewController){
            let userId : Int = userDefaults.integer(forKey: Constants.USER_DEFAULTS.userIdKey)
            profileView.loadUserAvailableBooks(userId: String(userId))
            profileView.userId = String(userId)
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

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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ProfileViewController {
            let view : ProfileViewController = segue.destination as! ProfileViewController
            view.bioLabel.text = "Testing"
            view.userNameLabel.text = "Dayna"
            
        }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let profileNavController = self.viewControllers![3] as! UINavigationController
        let profileView : ProfileViewController = profileNavController.viewControllers[0] as! ProfileViewController
        UserService().getUserProfile(userId: nil) { (dictionary) in
            let userId : Int = dictionary["id"] as! Int
            profileView.loadUserAvailableBooks(userId: String(userId))
            profileView.userId = String(userId)
            profileView.userNameLabel.text = dictionary["name"] as? String
            if let location : [String : AnyObject] = dictionary["location"] as? [String : AnyObject]{
                profileView.locationLabel.text = location["city"] as? String
            }
          
            if let avatarUrl : String = dictionary["avatar"] as? String{
                self.setAvatarImage(imageUrl: avatarUrl, imageView: profileView.avatarImage)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

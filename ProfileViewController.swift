//
//  ProfileViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let userDefaults = Foundation.UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().findBooksByUserId(token: token, userId: String(1001), page: String(0), size: String(5)) { (dictionary) in
            print(dictionary)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

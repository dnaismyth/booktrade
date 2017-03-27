//
//  UserService.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-27.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class UserService {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    func storeUserPlatformToken(){
        let device_token = userDefaults.string(forKey: "device_token")
        let access_token = userDefaults.string(forKey: "access_token")
        let data : [String:AnyObject] = [
            "deviceToken" : device_token as AnyObject
        ]
        PutRequest().jsonPut(postUrl: Constants.API.storeDeviceToken, token: access_token!, body: data, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation {
                print(dictionary)
            }
        })
    }
}

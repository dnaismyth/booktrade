    //
//  UserService.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-27.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class UserService {
    
    typealias FinishedFetchingData = (NSDictionary) -> ()
    
    let userDefaults = Foundation.UserDefaults.standard
    
    // Save the current user's device token
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
    
    // Get a user's profile information by their id
    func getUserProfile(userId : String?, completed : @escaping FinishedFetchingData){
        var url : String = Constants.API.getUserProfile
        if userId != nil {
            url = Constants.API.getUserProfile.appending("?id=").appending(userId!)
        }
        
        let access_token = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: url, token: access_token!) { (dictionary) in
            OperationQueue.main.addOperation {
                print(dictionary)
                completed(dictionary)
            }
        }
    }
}

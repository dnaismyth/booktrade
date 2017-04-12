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
            "value" : device_token as AnyObject
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
                if(userId == nil){
                    let userId : Int = dictionary["id"] as! Int
                    self.userDefaults.set(userId, forKey: "user_id")    // store the current user id
                }
                completed(dictionary)
            }
        }
    }
    
    // Update the current user's avatar
    func updateUserAvatar(avatar : String) {
        let access_token = userDefaults.string(forKey: "access_token")
        let data : [String : AnyObject] = [
            "value" : avatar as AnyObject
        ]
        PutRequest().jsonPut(postUrl: Constants.API.updateUserAvatar, token: access_token!, body: data) { (dictionary) in
            OperationQueue.main.addOperation{
                self.userDefaults.set(dictionary["avatar"], forKey: Constants.USER_DEFAULTS.userAvatar)
                print(dictionary)
            }
        }
    }
    
    // Update user's name
    func updateUserName(name : String, completed : @escaping FinishedFetchingData){
        let access_token = userDefaults.string(forKey: "access_token")
        let data : [String : AnyObject] = [
            "value" : name as AnyObject
        ]
        
        PutRequest().jsonPut(postUrl: Constants.API.updateUserName, token: access_token!, body: data) { (dictionary) in
            OperationQueue.main.addOperation {
                self.userDefaults.set(dictionary["name"], forKey: Constants.USER_DEFAULTS.nameKey)
                completed(dictionary)
            }
        }
    }
    
    // Update user's bio
    func updateUserBio(bio : String, completed : @escaping FinishedFetchingData){
        let access_token = userDefaults.string(forKey: "access_token")
        let data : [String : AnyObject] = [
            "value" : bio as AnyObject
        ]
        PutRequest().jsonPut(postUrl: Constants.API.updateUserBio, token: access_token!, body: data) { (dictionary) in
            OperationQueue.main.addOperation {
                self.userDefaults.set(dictionary["bio"], forKey: Constants.USER_DEFAULTS.bioKey)
                completed(dictionary)
            }
        }
        
    }
    
    // Update the user's location
    func updateUserLocation(location : [String : AnyObject], completed : @escaping FinishedFetchingData){
        let access_token = userDefaults.string(forKey: "access_token")!
        PutRequest().jsonPut(postUrl: Constants.API.updateUserLocation, token: access_token, body: location) { (dictionary) in
            OperationQueue.main.addOperation {
                if(NSDictionary(dictionary: location).isEqual(dictionary["location"])){
                    self.userDefaults.set(location, forKey: Constants.USER_DEFAULTS.locationKey)
                }
                completed(dictionary)
            }
        }
    }
    
    // Get temporary s3 token to allow put into S3 bucket
    func getTemporaryS3Token(completed : @escaping FinishedFetchingData){
        let access_token = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.getS3Token, token: access_token!) { (dictionary) in
            OperationQueue.main.addOperation {
                print(dictionary)
                completed(dictionary)
            }
        }
    }
    
    // Update the current user's password
    func updateUserPassword(data : [String : AnyObject], completed : @escaping FinishedFetchingData){
        let access_token = userDefaults.string(forKey: "access_token")!
        PutRequest().jsonPut(postUrl: Constants.API.changePassword, token: access_token, body: data) { (dictionary) in
            OperationQueue.main.addOperation {
                completed(dictionary)
            }
        }
    }
    
    // Update push notification settings
    func updatePushNotificationSettings(pushNotification : Bool, completed : @escaping FinishedFetchingData){
        let access_token = userDefaults.string(forKey: "access_token")!
        var value : String = "false"
        if(pushNotification == true){
            value = "true"
        }
        let data : [String : AnyObject] = [
            "value" : value as AnyObject
        ]
        PutRequest().jsonPut(postUrl: Constants.API.updatePushNotification, token: access_token, body: data) { (dictionary) in
            OperationQueue.main.addOperation {
                if(dictionary["pushNotification"] as! Bool == pushNotification){
                    self.userDefaults.set(pushNotification, forKey : Constants.USER_DEFAULTS.notificationKey)
                }
                completed(dictionary)
            }
        }
    }
    
}

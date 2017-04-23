//
//  FirebaseService.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-22.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService {
    
    // MARK: Properties
    typealias FinishedFetchingUser = (FirebaseUser) -> ()
    typealias FinishedFetchingMessages = (FirebaseMessage) -> ()
    
    // User reference to firebase database
    let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    
    let convoRef : FIRDatabaseReference = FIRDatabase.database().reference().child("conversations")
    
    //  Authenticate a firebase user from custom token provided by backend service
    func authenticateUser(customToken : String) {
        FIRAuth.auth()?.signIn(withCustomToken: customToken, completion: { (firebaseUser : FIRUser?, error) in
            if(error != nil){
                print(error!)
                return
            }
            // Successfully authenticated user
            print("User successfully authenticated")
        })
    }
    
    func fetchFirebaseUser(userId : String, completed : @escaping FinishedFetchingUser){
        let user = FirebaseUser()
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                user.id = snapshot.key
                print(user.id)
                self.setUserProperties(dictionary: dictionary, user: user)
            }
            completed(user)
        })
    }
    
    func setUserProperties(dictionary : [String : AnyObject], user : FirebaseUser){
        if let avatar = dictionary["avatar"] as? String {
            user.avatar = avatar
        }
        
        if let name = dictionary["name"] as? String {
            user.name = name
        }
        
        if let email = dictionary["email"] as? String {
            user.email = email
        }
    }
    
    
    // Fetch conversations from firebase by their id
    func fetchConversation(convoId : String, completed : @escaping FinishedFetchingMessages){
        print(convoId)
        let currentConvoRef = convoRef.child(convoId)
        currentConvoRef.child("messages").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = FirebaseMessage()
                message.setValuesForKeys(dictionary)
                completed(message)
            }
        })
    
    }
    
}

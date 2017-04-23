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
    typealias FinishedFetchingMessages = ([FirebaseMessage]) -> ()
    
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
                user.id = userId
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
        var messages : [FirebaseMessage] = []
        convoRef.child(convoId).observe(.value, with: { (snapshot) in
            if(snapshot.hasChild("messages")){
                let firebaseMessages = snapshot.childSnapshot(forPath: "messages")
                for child in firebaseMessages.children {
                    messages.append(self.setMessageProperties(msg: child as! FIRDataSnapshot))
                }
            }
            completed(messages)
        })
    }
    
    
    // Set message properties of each message within a conversation
    func setMessageProperties(msg : FIRDataSnapshot) -> FirebaseMessage {
        let firebaseMessage = FirebaseMessage()
        if(msg.hasChild("text")){
            firebaseMessage.text = msg.childSnapshot(forPath: "text").value as! String?
        }
        
        if(msg.hasChild("sent_date")){
            firebaseMessage.sentDate = msg.childSnapshot(forPath: "sent_date").value as! String?
        }
        
        if(msg.hasChild("sent_from_id")){
            firebaseMessage.sentFromId = msg.childSnapshot(forPath: "sent_from_id").value as! String?
        }
        return firebaseMessage
   }
    
}

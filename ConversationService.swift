//
//  ConversationService.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-01.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class ConversationService {
    
    typealias FinishedFetchingData = (NSDictionary) -> ()

    // Get the current user's conversations where they are the recipient
    func getRecipientConversations(page : String, size : String, token : String, completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.getRecipientConversations.appending("?page=").appending(page).appending("&size=").appending(size)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
    // Get the current user's conversations where they are the initiator
    func getInitiatorConversations(page : String, size : String, token : String, completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.getInitiatorConversations.appending("?page=").appending(page).appending("&size=").appending(size)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
    func getConversationById(id : String, token : String, completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.getConversationById.replacingOccurrences(of: "{id}", with: id)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
}

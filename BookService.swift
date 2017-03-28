//
//  BookService.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-27.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class BookService {
    
    public func createNewBookPosting(book : [String : AnyObject], token : String) -> NSDictionary {
        var response : NSDictionary = [:]
        PostRequest().jsonPost(postUrl: Constants.API.createBookPosting, token: token, body: book) { (dictionary) in
            response = dictionary
        }
        return response
    }
}

//
//  BookService.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-27.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class BookService {
    
    typealias FinishedFetchingData = (NSDictionary) -> ()

    public func createNewBookPosting(book : [String : AnyObject], token : String, completed : @escaping FinishedFetchingData) {
        PostRequest().jsonPost(postUrl: Constants.API.createBookPosting, token: token, body: book) { (dictionary) in
            completed(dictionary)
        }
    }
    
    public func findBooksByUserId(token : String, userId : String, page : String, size: String, completed : @escaping FinishedFetchingData) {
        let url : String = Constants.API.getBooksByUserId.replacingOccurrences(of: "{userId}", with: userId).appending("?page=").appending(page).appending("&size=").appending(size)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
}

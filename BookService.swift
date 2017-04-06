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

    // Create a new available book
    public func createNewBookPosting(book : [String : AnyObject], token : String, completed : @escaping FinishedFetchingData) {
        PostRequest().jsonPost(postUrl: Constants.API.createBookPosting, token: token, body: book) { (dictionary) in
            completed(dictionary)
        }
    }
    
    // Find all available books by user
    public func findAvailableBooksByUserId(token : String, userId : String, page : String, size: String, completed : @escaping FinishedFetchingData) {
        let url : String = Constants.API.getAvailableBooksByUserId.replacingOccurrences(of: "{userId}", with: userId).appending("&page=").appending(page).appending("&size=").appending(size)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
    // Find all unavailable books from user
    public func findUnavailableBooksByUserId(token : String, userId : String, page : String, size: String, completed : @escaping FinishedFetchingData) {
        let url : String = Constants.API.getUnavailableBooksByUserId.replacingOccurrences(of: "{userId}", with: userId).appending("?page=").appending(page).appending("&size=").appending(size)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
    // Create a book comment/message
    public func createBookComment(token : String, bookId : String, comment : [String : AnyObject], completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.createBookComment.replacingOccurrences(of: "{bookId}", with: bookId)
        PostRequest().jsonPost(postUrl: url, token: token, body: comment) { (dictionary) in
            completed(dictionary)
        }
    }
    
    // Get most recent books (these will display upon first entering the search page)
    public func getMostRecentBooks(token : String, page : String, size : String, completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.getRecentBooks.appending("?page=").appending(page).appending("&size=").appending(size)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
    // Search books
    public func searchBooks(token : String, value : String, page : String, size : String, completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.searchBooks.appending("?page=").appending(page).appending("&size=").appending(size).appending("&value=").appending(value)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
}

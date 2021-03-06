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
    
    // Filtered book search
    public func filterSearchBooks(token : String, filter : String, page : String, size : String, completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.filterSearch.appending("?page=").appending(page).appending("&size=").appending(size).appending(filter)
        print(url)
        GetRequest().HTTPGet(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
    // Allow owner to update the status of the book
    public func updateBookStatus(token : String, data : [String : AnyObject], completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.updateBookStatus
        PutRequest().jsonPut(postUrl: url, token: token, body: data) { (dictionary) in
            completed(dictionary)
        }
    }
    
    public func deleteBook(token : String, bookId : String, completed : @escaping FinishedFetchingData){
        let url : String = Constants.API.deleteBook.replacingOccurrences(of: "{bookId}", with: bookId)
        DeleteRequest().HTTPDelete(getUrl: url, token: token) { (dictionary) in
            completed(dictionary)
        }
    }
    
    /// Update a book by it's provided id
    public func updateBook(token: String, bookId: String, book: [String: AnyObject], completed: @escaping FinishedFetchingData){
        let url: String = Constants.API.updateBookPosting.replacingOccurrences(of: "{bookId}", with: bookId)
        PutRequest().jsonPut(postUrl: url, token: token, body: book) { (dictionary) in
            completed(dictionary)
        }
    }
    
}

//
//  Constants.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-22.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

// Application Constants
struct Constants {
    
    struct DEVELOPER {
        static let goodreadsKey = "MvQ8h51ENLLLXO6jo3QNw"
        static let goodreadsSecret = "HfxZb1X8sm3kaypNAucEvCMzUh9QNlXAxJqwY9qDY"
    }
    
    struct GOODREADS {
        static let searchByIsbn : String = "https://www.goodreads.com/search/index.xml?key=".appending(DEVELOPER.goodreadsKey).appending("&q=")
    }
    
}

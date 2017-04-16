//
//  Utilities.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-08.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class Utilities{
    
    static func buildLocationLabel(location : [String : AnyObject]) -> String{
        var label : String = location["city"]!.appending(", ")
        label = label.appending(location["province"] as! String)
        return label
    }
    
}

//
//  Utilities.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-08.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

class Utilities{
    
    static let milesInKilometer : Float = 0.621371 // (miles in one kilometer)
    
    static func buildLocationLabel(location : [String : AnyObject]) -> String{
        var label : String = location["city"]!.appending(", ")
        label = label.appending(location["province"] as! String)
        return label
    }
    
    static func kilometersToMiles(km : Float) -> Float {
        return milesInKilometer * km
    }
    
    static func setImage(imageUrl : String, imageView : UIImageView){
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL){
                if let imageUrl = UIImage(data: data as Data) {
                    imageView.image = imageUrl
                }
            }
        }
    }
}

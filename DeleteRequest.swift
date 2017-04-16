//
//  DeleteRequest.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-11.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

import Foundation

class DeleteRequest {
    
    typealias CompletionHandler = (NSDictionary) -> ()
    
    public func HTTPDelete(getUrl : String, token: String, completionHandler: @escaping (CompletionHandler))  {
        
        let formatUrl = Constants.API.baseUrl.appending(getUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                print(error ?? "Error sending get request.")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
                if(httpResponse.statusCode == 401){
                    UserService().refreshToken(completed: { (dictionary) in
                        UserService().storeLoginResponse(response: dictionary, completed: {})
                    })
                }
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            completionHandler(json as! NSDictionary)
        }
        
        task.resume()
    }
}

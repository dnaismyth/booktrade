//
//  PutRequest.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-27.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation


class PutRequest{
    
    typealias CompletionHandler = (NSDictionary) -> ()
    
    public func jsonPut(postUrl: String, token: String, body: [String : AnyObject], completionHandler: @escaping (CompletionHandler)){
        
        let formatUrl = Constants.API.baseUrl.appending(postUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        if(body.count > 0){
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data,response,error) in
            if error != nil{
                print(error?.localizedDescription ?? "Error")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
                if(httpResponse.statusCode == 401){
                    UserService().refreshToken(completed: { (dictionary) in
                        UserService().storeLoginResponse(response: dictionary, completed: {})
                    })
                }
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if json != nil {
                    completionHandler(json!)
                }
            } catch let error as NSError {
                completionHandler([String: String]() as NSDictionary)
                print(error)
            }
        }
        task.resume()
        
    }
}

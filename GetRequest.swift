//
//  GetRequest.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-22.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//
import Foundation

class GetRequest : NSObject, XMLParserDelegate{
    
    var parser = XMLParser()
    var books : NSMutableDictionary = [:]
    var strXMLData:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    
    typealias CompletionHandler = (NSDictionary) -> ()
    
    public func HTTPGetXML(getUrl : String, token: String?, completionHandler: @escaping (CompletionHandler))  {
        
        let url = URL(string:getUrl)!
        parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        print(url)
        let success:Bool = parser.parse()
        
        if success {
            print("parse success!")
            
            completionHandler(books)
        } else {
            print("parse failure!")
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement=elementName
        if(elementName=="search" )
        {
            passData=true;
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement="";
        if(elementName=="work")
        {
            passData=false;
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if(passData){
            books[currentElement] = string
        }
        
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: %@", parseError)
    }
    
    public func HTTPGet(getUrl : String, token: String, completionHandler: @escaping (CompletionHandler))  {
        
        let formatUrl = Constants.API.baseUrl.appending(getUrl)
        print(formatUrl)
        let url = URL(string:formatUrl)!
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
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

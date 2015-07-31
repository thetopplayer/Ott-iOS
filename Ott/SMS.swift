//
//  SMS.swift
//  Ott
//
//  Created by Max on 7/29/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


func randomNumericCode(length length: Int) -> String {
    
    var result = String()
    for _ in 1...length {
        result = result + "\(arc4random_uniform(9))"
    }
    return result
}



class SMS {
    
    private let twilioAccountSID = "ACa1bfcdc6df9aca48e2192875f78a40d3"
    private let twilioAuthToken = "84376d6d7ee0a8ec508b5edc9b26d53f"
    private let twilioAccountPhoneNumber = "+14086101736"
    
    static var sharedInstance: SMS = {
        return SMS()
        }()
    
    
    private init() {
    
    }

    
    func sendMessage(message message: String, phoneNumber: String, completion: ((success: Bool, message: String?) -> Void)?) {
        
        let loginString = "\(twilioAccountSID):\(twilioAuthToken)"
        let urlString = "https://\(loginString)@api.twilio.com/2010-04-01/Accounts/\(twilioAccountSID)/Messages.json/"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        
        let bodyString = NSString(format:"From=%@&To=%@&Body=%@", twilioAccountPhoneNumber, phoneNumber, message)
        let bodyData: NSData = bodyString.dataUsingEncoding(NSUTF8StringEncoding)!
        request.HTTPBody = bodyData
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if error == nil {
                
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    print("\(jsonResult)")
                    
                    if let completion = completion {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            let success = jsonResult["code"] == nil
                            let errMessage = jsonResult["message"] as? String
                            completion(success: success, message: errMessage)
                        }
                    }
                }
                catch {
                    
                    if let completion = completion {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(success: true, message: nil)
                        }
                    }
                }

            }
            else {
                
                if let completion = completion {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let message = error!.localizedDescription
                        completion(success: true, message: message)
                    }
                }
            }
        }
    }
}

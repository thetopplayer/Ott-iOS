//
//  ScanTransformer.swift
//  Ott
//
//  Created by Max on 9/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


/*
    Used to encode and decode PFObject objectIds from QRCodes

    objectId -> code encoding a prefix and identifier for class type -> QRCode
    QRCode -> code -> PFQuery for appropriate class and objectID

*/



import UIKit

class ScanTransformer {
    
    static var sharedInstance: ScanTransformer = {
        return ScanTransformer()
        }()
    
    
    private let codePrefixLength = 4
    private let queryCodePosition = 3
    private let codePrefix = "ott"
    
    enum QueryType: Character {
        case User = "0"
        case Topic = "1"
        
        func allCodes() -> [Character] {
            return [User.rawValue, Topic.rawValue]
        }
        
    }
    

    private func queryTypeForCode(text: String) -> QueryType? {
        
        if let char = text.characterAtIndex(queryCodePosition) {
            return QueryType(rawValue: char)
        }
        return nil
    }
    
    
    private func queryTypeForObject(object: PFObject) -> QueryType? {
        
        var theType: QueryType?
        switch object {
            
        case is User:
            theType = .User
            
        case is Topic:
            theType = .Topic
            
        default:
            print("Error:  invalid type")
        }
        
        return theType
    }

    
    func codeAppearsValid(code: String) -> Bool {
        
        if code.hasPrefix(codePrefix) {
            return queryTypeForCode(code) != nil
        }
        return false
    }
    
    
    private func objectID(fromCode code: String) -> String? {
        
        return code.substringToEnd(startingAt: codePrefixLength)
    }
    
    
    func queryForCode(code: String) -> PFQuery? {
        
        var query: PFQuery?
        switch queryTypeForCode(code)! {
            
        case .User:
            query = User.query()
            
        case .Topic:
            query = Topic.query()
            
        }
        
        if let objectID = objectID(fromCode: code) {
            
            query?.whereKey("objectId", equalTo: objectID)
            return query
        }
        
        return nil
    }

    
    func codeForObject(object: PFObject) -> String? {
        
        guard let objectID = object.objectId else {
            print ("Error:  object has no Id")
            return nil
        }
        
        if let theType = queryTypeForObject(object) {
            var result = String(codePrefix)
            result.append(theType.rawValue)
            return result + objectID
        }
        
        return nil
    }
    
    
    func image(fromCode code: String) -> UIImage? {
        
        return nil
    }
    

}
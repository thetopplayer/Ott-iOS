//
//  ParseOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/*

    Abstract base class for operations interacting with Parse

*/

import UIKit

class ParseOperation: Operation {

    override init() {
        
        super.init()
        
        addCondition(reachabilityCondition)
        addObserver(timeoutObserver)
    }
    
    
    //MARK: - Conditions and Observers
    
    let reachabilityCondition: ReachabilityCondition = {
        
        let host = NSURL(string: "https://api.parse.com")
        return ReachabilityCondition(host: host!)
        }()
    
    
    let timeoutObserver = TimeoutObserver(timeout: 15)
    
    
    
    //MARK: - Background Task Tracking
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    /// let system know this is a background task that should finish before the application moves to the background
    func logBackgroundTask() {
        
        backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithName("net.senisa.ott.backgroundTask", expirationHandler: nil)
    }
    
    /// lets the system know this background task has been completed, and the app can go into background state if necessary
    func clearBackgroundTask() {
        
        if let backgroundTaskIdentifier = backgroundTaskIdentifier {
            UIApplication.sharedApplication().endBackgroundTask(backgroundTaskIdentifier)
        }
    }
    
    
    //MARK: - Caching
    
    enum DataSource {
        case Cache, Server
    }
    
    
    static func replaceCache(pinName: String, withObjects newObjects: [PFObject]) {
        
        do {
            
            let _ = try? PFObject.unpinAllObjectsWithName(pinName)
            updateCache(pinName, withObjects: newObjects)
        }
    }
    
    
    static func updateCache(pinName: String, withObjects objects: [PFObject]) {
        
        do {
            
            try PFObject.pinAll(Array(objects), withName: pinName)
        }
        catch let error as NSError {
            NSLog("error in updateCache = %@", error)
        }
    }
    
    
    static func cachedObjects(pinName pinName: String) -> [PFObject] {
        
        let query = PFObject.query()!
        query.fromPinWithName(pinName)
        
        let objects = try? query.findObjects()
        
        if objects == nil {
            return []
        }
        return objects!
    }

}

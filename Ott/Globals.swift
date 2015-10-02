//
//  Globals.swift
//  Ott
//
//  Created by Max on 6/30/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


//MARK: - Vars

class Globals {
    
   static let sharedInstance = Globals()
    
    
    //MARK: - Login and Sign Up
    
    var handleUsedToLogin = ""
    var nameUsedToLogin = ""
    var phoneNumberUsedToLogin = ""
    
    
    //MARK: - User Defaults
    
    var defaultFetchSinceDate: NSDate {
        let weekAgo = NSDate().daysFrom(-7)
        return weekAgo
    }
    
    private let lastUpdatedLocalTopicsKey = "lastUpdatedLocalTopicsKey"
    var lastUpdatedLocalTopics: NSDate {
        
        get {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(lastUpdatedLocalTopicsKey) as? NSDate {
                return date
            }
            return defaultFetchSinceDate
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: lastUpdatedLocalTopicsKey)
        }
    }
    
    private let lastUpdatedFollowedUsersTopicsKey = "lastUpdatedFollowedUsersTopics"
    var lastUpdatedFollowedUsersTopics: NSDate {
        
        get {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(lastUpdatedFollowedUsersTopicsKey) as? NSDate {
                return date
            }
            return defaultFetchSinceDate
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: lastUpdatedFollowedUsersTopicsKey)
        }
    }
    
    
    private let requestedAccessUserDefaultsKey = "requestedCameraAccess"
    var didRequestCameraAccess: Bool {
        
        get {

            return NSUserDefaults.standardUserDefaults().boolForKey(requestedAccessUserDefaultsKey)
        }
        
        set {
            
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: self.requestedAccessUserDefaultsKey)
        }
    }
    
    
    private let remindersToPostKey = "remindersToPost"
    var remindersToPostToTopic: Int {
        
        get {
            
            return NSUserDefaults.standardUserDefaults().integerForKey(remindersToPostKey)
        }
        
        set {
            
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: remindersToPostKey)
        }
    }
}




//MARK: - Utilities

func openSettings() {
    
    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
    }
}



//MARK: - Directories

func documentsDirectory() -> String {
    
    do {
        
        let documentURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
        return documentURL.path!
    }
    catch {
        print("error getting document directory")
        return ""
    }
}


func documentsDirectory(withSubpath subpath: String) -> String? {
    
    do {
        
        let documentURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
        return documentURL.path! + subpath
    }
    catch {
        print("error getting document directory")
        return nil
    }
}



//MARK: - User Defaults





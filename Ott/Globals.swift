//
//  Globals.swift
//  Ott
//
//  Created by Max on 6/30/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


//MARK: - Vars

struct Globals {
    
    var handleUsedToLogin = ""
    var nameUsedToLogin = ""
    var phoneNumberUsedToLogin = ""
}

var globals = Globals()


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

private let signedUpUserDefaultsKey = "signedUp"
func userSignedUp() -> Bool {
    
    return NSUserDefaults.standardUserDefaults().boolForKey(signedUpUserDefaultsKey)
}


func setUserSignedUp(value: Bool) {
    
    NSUserDefaults.standardUserDefaults().setBool(value, forKey: signedUpUserDefaultsKey)
}


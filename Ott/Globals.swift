//
//  Globals.swift
//  Ott
//
//  Created by Max on 6/30/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

func openSettings() {
    
    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
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


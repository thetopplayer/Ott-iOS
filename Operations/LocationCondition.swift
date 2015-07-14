/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Adapted from Apple's NSOperation Earthquake app code to present alerts notifying
the user of the location access requirement and directing to Settings if it's not been set
*/

import CoreLocation
import UIKit


/// A condition for verifying access to the user's location.
struct LocationCondition: OperationCondition {
    /**
        Declare a new enum instead of using `CLAuthorizationStatus`, because that
        enum has more case values than are necessary for our purposes.
    */
    enum Usage {
        case WhenInUse
        case Always
    }
    
    static let name = "Location"
    static let locationServicesEnabledKey = "CLLocationServicesEnabled"
    static let authorizationStatusKey = "CLAuthorizationStatus"
    static let isMutuallyExclusive = false
    
    let usage: Usage
    
    init(usage: Usage) {
        self.usage = usage
    }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return LocationPermissionOperation(usage: usage)
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        let enabled = CLLocationManager.locationServicesEnabled()
        let actual = CLLocationManager.authorizationStatus()
        
        var error: NSError?

        // There are several factors to consider when evaluating this condition
        switch (enabled, usage, actual) {
            case (true, _, .AuthorizedAlways):
                // The service is enabled, and we have "Always" permission -> condition satisfied.
                break

            case (true, .WhenInUse, .AuthorizedWhenInUse):
                /*
                    The service is enabled, and we have and need "WhenInUse" 
                    permission -> condition satisfied.
                */
                break

            default:
                /*
                    Anything else is an error. Maybe location services are disabled,
                    or maybe we need "Always" permission but only have "WhenInUse",
                    or maybe access has been restricted or denied,
                    or maybe access hasn't been request yet.
                    
                    The last case would happen if this condition were wrapped in a `SilentCondition`.
                */
                error = NSError(code: .ConditionFailed, userInfo: [
                    OperationConditionKey: self.dynamicType.name,
                    self.dynamicType.locationServicesEnabledKey: enabled,
                    self.dynamicType.authorizationStatusKey: Int(actual.rawValue)
                ])
        }
        
        if let error = error {
            completion(.Failed(error))
        }
        else {
            completion(.Satisfied)
        }
    }
}

/**
    A private `Operation` that will request permission to access the user's location, 
    if permission has not already been granted.
*/
private class LocationPermissionOperation: Operation {
    let usage: LocationCondition.Usage
    var manager: CLLocationManager?
    
    init(usage: LocationCondition.Usage) {
        self.usage = usage
        super.init()
        /*
            This is an operation that potentially presents an alert so it should 
            be mutually exclusive with anything else that presents an alert.
        */
        addCondition(AlertPresentation())
    }
    
    override func execute() {
        /*
            Not only do we need to handle the "Not Determined" case, but we also 
        need to handle the "upgrade" (.WhenInUse -> .Always) case.
        */
        switch (CLLocationManager.authorizationStatus(), usage) {
            
        case (.NotDetermined, _):
            dispatch_async(dispatch_get_main_queue()) {
                self.notifyUserOfAccessRequirement()
            }
            
           
        case (.AuthorizedWhenInUse, .Always):
            dispatch_async(dispatch_get_main_queue()) {
                self.requestPermission()
            }
            
            
        case (.Restricted, _):
            dispatch_async(dispatch_get_main_queue()) {
                self.notifyUserToChangeSettings()
            }
            
            
        case (.Denied, _):
            dispatch_async(dispatch_get_main_queue()) {
                self.notifyUserToChangeSettings()
            }
            
            
        default:
            finish()
        }
    }
    
    
    private func notifyUserOfAccessRequirement() {
        
        guard let controller = UIApplication.sharedApplication().keyWindow?.rootViewController else {
            return
        }
        
        let alertViewController = UIAlertController(title: "Location Services", message: "In order to post topics and ratings, please activate location services when prompted.", preferredStyle: .Alert)
        
        let nextAction = UIAlertAction(title: "Next", style: UIAlertActionStyle.Default, handler: { action in self.requestPermission() })
        
        alertViewController.addAction(nextAction)
        
        controller.presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    
    private func notifyUserToChangeSettings() {
        
        guard let controller = UIApplication.sharedApplication().keyWindow?.rootViewController else {
            return
        }
        
        let alertViewController = UIAlertController(title: "Unable To Access Location", message: "Please enable location services in Settings>Preferences>Privacy to enable this feature.", preferredStyle: .Alert)
        
        let viewSettingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { action in
            openSettings()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in controller.dismissViewControllerAnimated(true, completion: nil) })
        
        alertViewController.addAction(viewSettingsAction)
        alertViewController.addAction(cancelAction)
        
        controller.presentViewController(alertViewController, animated: true, completion: { self.finish() })
    }
    
    
    private func requestPermission() {
        
        manager = CLLocationManager()
        manager?.delegate = self

        let key: String
        
        switch usage {
            case .WhenInUse:
                key = "NSLocationWhenInUseUsageDescription"
                manager?.requestWhenInUseAuthorization()
        
            case .Always:
                key = "NSLocationAlwaysUsageDescription"
                manager?.requestAlwaysAuthorization()
        }
        
        // This is helpful when developing the app.
        assert(NSBundle.mainBundle().objectForInfoDictionaryKey(key) != nil, "Requesting location permission requires the \(key) key in your Info.plist")
    }
    
}

extension LocationPermissionOperation: CLLocationManagerDelegate {
    
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if manager == self.manager && executing && status != .NotDetermined {
            finish()
        }
    }
}

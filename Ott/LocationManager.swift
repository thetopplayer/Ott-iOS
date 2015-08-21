//
//  LocationManager.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: CLLocationManager, CLLocationManagerDelegate {

    struct Notifications {
        
        static let SignificantLocationChangeDidOccur = "SignificantLocationChangeDidOccur"
    }
    
    
    static var sharedInstance: LocationManager = {
        return LocationManager()
        }()
    
    
    private let geoCoder: CLGeocoder
    private let accuracy = CLLocationAccuracy(100)
    private let significantLocationDifference = Double(1000)

    
    //MARK: - Lifecycle
    
    private override init() {
        
        geoCoder = CLGeocoder()
        
        super.init()
        delegate = self
        desiredAccuracy = accuracy
        
        if permissionGranted {
            startUpdatingLocation()
        }
    }
    
    
    deinit {
        stopUpdatingLocation()
    }
    

    
    //MARK: - Data
    
    var locationName: String? {
        
        var result: String?
        if let placemark = placemark {
            
            if let areaOfInterest = placemark.areasOfInterest?.first {
                return areaOfInterest
            }
            
            var parts = [String]()
            
//            if placemark.thoroughfare != nil {
//                parts.append(placemark.thoroughfare)
//            }
            if placemark.locality != nil {
                parts.append(placemark.locality!)
            }
            if placemark.administrativeArea != nil {
                parts.append(placemark.administrativeArea!)
            }
            
            for placemarkPart in parts {
                
                if result != nil {
                    result! += ", " + placemarkPart
                }
                else {
                    result = placemarkPart
                }
            }
        }
        
        return result
    }
    
    
    var placemark: CLPlacemark?
    
    private let _geoCodingDelay = 2
    private var _isGeocoding = false
    private var _geocodedLocation: CLLocation?
    private var _lastFetchedGeocode: NSDate = NSDate.distantPast()
    private func reverseGeocode(location: CLLocation) {
        
        if _isGeocoding {
            return
        }
        
        if _lastFetchedGeocode.minutesFromNow(absolute: true) > _geoCodingDelay {
            
            _lastFetchedGeocode = NSDate()
            _isGeocoding = true
            placemark = nil
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                if error == nil {
                    
                    if let placemarks = placemarks {
                        
                        self._geocodedLocation = location
                        self.placemark = placemarks.first
                    }
                }
                self._isGeocoding = false
            })
        }
        else {
            _geocodedLocation = location
        }
    }
    
    
    func distanceFromCurrentLocation(location: CLLocation) -> CLLocationDistance? {
        
        return self.location?.distanceFromLocation(location)
    }
    
    
    
    //MARK: - Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if permissionGranted {
            startUpdatingLocation()
        }

        if let completionBlock = permissionCompletionBlock {
            
            dispatch_async(dispatch_get_main_queue()) {
                completionBlock(granted: self.permissionGranted)
            }
        }
    }
    
    
    var previouslyPostedLocation: CLLocation?
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locations.first else {
            return
        }
        
        reverseGeocode(currentLocation)
        
        if let priorLocation = previouslyPostedLocation {
            
            if currentLocation.distanceFromLocation(priorLocation) > significantLocationDifference {
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.SignificantLocationChangeDidOccur, object: self)
                
                previouslyPostedLocation = currentLocation
            }
        }
        else {
            
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.SignificantLocationChangeDidOccur, object: self)
            
            previouslyPostedLocation = currentLocation
        }
    }
    
    
    
    //MARK: - Permission
    
    var permissionGranted: Bool {
        let status = CLLocationManager.authorizationStatus()
        return (status == .AuthorizedAlways) || (status == .AuthorizedWhenInUse)
    }
    
    
    var permissionCompletionBlock: ((granted: Bool) -> Void)?
    
    func requestPermission(completion: (granted: Bool) -> Void) {
        
        func notifyUserOfAccessRequirement() {
            
            guard let controller = topmostViewController() else {
                return
            }
            
            let alertViewController = UIAlertController(title: "Location Services", message: "In order to post topics and ratings, please activate location services when prompted.", preferredStyle: .Alert)
            
            let nextAction = UIAlertAction(title: "Next", style: UIAlertActionStyle.Default, handler: { action in self.requestWhenInUseAuthorization() })
            
            alertViewController.addAction(nextAction)
            controller.presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        
        func notifyUserToChangeSettings() {
            
            guard let controller = topmostViewController() else {
                return
            }
            
            let alertViewController = UIAlertController(title: "Unable To Access Location", message: "Please enable location services in Settings>Preferences>Privacy to enable this feature.", preferredStyle: .Alert)
            
            let viewSettingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { action in
                openSettings()
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in controller.dismissViewControllerAnimated(true, completion: nil) })
            
            alertViewController.addAction(viewSettingsAction)
            alertViewController.addAction(cancelAction)
            
            controller.presentViewController(alertViewController, animated: true, completion: {  })
        }
        
        
        permissionCompletionBlock = completion
        
        switch (CLLocationManager.authorizationStatus()) {
            
        case .NotDetermined:
            dispatch_async(dispatch_get_main_queue()) {
                notifyUserOfAccessRequirement()
            }
            
            
        case .Restricted:
            dispatch_async(dispatch_get_main_queue()) {
                notifyUserToChangeSettings()
            }
            
            
        case .Denied:
            dispatch_async(dispatch_get_main_queue()) {
                notifyUserToChangeSettings()
            }
            
        default:
            ()
            
        }
    }
}

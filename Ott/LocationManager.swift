//
//  LocationManager.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreLocation


//MARK: - Placemark

extension CLPlacemark {
    
    enum Keys: String {
        
        case Name = "name"
        case AreaOfInterest = "areaOfInterest"
        case Thoroughfare = "thoroughfare"
        case Locality = "locality"
        case SubLocality = "subLocality"
        case AdministativeArea = "adminArea"
        case SubAdministativeArea = "subAdminArea"
        case Country = "country"
    }
    
    
    func toDictionary() -> NSDictionary {
        
        var results = [String: String]()
        
        if let name = name {
            results[Keys.Name.rawValue] = name
        }
        
        if let areaOfInterest = areasOfInterest?.first {
            results[Keys.AreaOfInterest.rawValue] = areaOfInterest
        }
        
        if let thoroughfare = thoroughfare {
            results[Keys.Thoroughfare.rawValue] = thoroughfare
        }
        
        if let locality = locality {
            results[Keys.Locality.rawValue] = locality
        }
        
        if let subLocality = subLocality {
            results[Keys.SubLocality.rawValue] = subLocality
        }
        
        if let administrativeArea = administrativeArea {
            results[Keys.AdministativeArea.rawValue] = administrativeArea
        }
        
        if let subAdministrativeArea = subAdministrativeArea {
            results[Keys.SubAdministativeArea.rawValue] = subAdministrativeArea
        }
        
        if let country = country {
            results[Keys.Country.rawValue] = country
        }
        
        return results
    }
}




//MARK: - LocationManager

class LocationManager: CLLocationManager, CLLocationManagerDelegate {

    struct Notifications {
        
        static let LocationDidChange = "LocationDidChange"
        static let PermissionDidChange = "PermissionDidChange"
    }
    
    static let sharedInstance = LocationManager()
    
    lazy private var geoCoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    private let notificationFilterDistance = CLLocationDistance(500)

    
    //MARK: - Lifecycle
    
    private override init() {
        
        super.init()
        delegate = self
        distanceFilter = notificationFilterDistance
    }
    
    
    deinit {
        stop()
    }
    

    func start() {
        
        if permissionGranted {
            startUpdatingLocation()
        }
    }
    
    
    func stop() {
        
        stopUpdatingLocation()
    }
    
    
    //MARK: - Data
    
    private let placemarkArchive = documentsDirectory() + "/placemark"
    var placemark: CLPlacemark? {
    
        set {
            let didArchive = NSKeyedArchiver.archiveRootObject(newValue!, toFile: placemarkArchive)
            if !didArchive {
                print("failed to archive placemark")
            }
        }
        
        get {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(placemarkArchive) as? CLPlacemark
        }
    }

    
    private func placemarkIsWithinDistance(distance: CLLocationDistance) -> Bool {
    
        if let placemark = placemark {
            return distanceFromCurrentLocation(placemark.location!) <= distance
        }
        else {
            return false
        }
    }
    
    
    private func shouldReverseGeocodeLocation() -> Bool {
        
        if let placemark = placemark {
            
            let meaningfulNameDistance = CLLocationDistance(100)
            return distanceFromCurrentLocation(placemark.location!) <= meaningfulNameDistance
        }
        else {
            
            return true
        }
    }
    
    
    private var isGeocoding = false
    func reverseGeocodeCurrentLocation() {
        
        if isGeocoding {
            return
        }

        if placemarkIsWithinDistance(CLLocationDistance(25)) {
            return
        }
        
        print("reverse geocoding")
        
        isGeocoding = true
        geoCoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) -> Void in
            
            if error == nil {
                if let placemarks = placemarks {
                    self.placemark = placemarks.first
                }
            }
            
            self.isGeocoding = false
        })
    }
    

    func distanceFromCurrentLocation(location: CLLocation) -> CLLocationDistance? {
        
        return self.location?.distanceFromLocation(location)
    }
    
    
    
    //MARK: - Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.PermissionDidChange, object: self)
        
        if permissionGranted {
            startUpdatingLocation()
        }

        if let completionBlock = permissionCompletionBlock {
            
            dispatch_async(dispatch_get_main_queue()) {
                completionBlock(granted: self.permissionGranted)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = placemark?.location {
            if distanceFromCurrentLocation(lastLocation) < notificationFilterDistance {
                return
           }
        }
        
        reverseGeocodeCurrentLocation()

        NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.Notifications.LocationDidChange, object: self)
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

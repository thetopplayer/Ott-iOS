//
//  TableViewCell.swift
//  Ott
//
//  Created by Max on 7/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreLocation


class TableViewCell: UITableViewCell {

    @IBOutlet var innerContentContainer: UIView?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        
        contentView.backgroundColor = UIColor.background()
        innerContentContainer?.backgroundColor = UIColor.whiteColor()
        innerContentContainer?.addBorder()
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if let frame = innerContentContainer?.frame {
            selectedBackgroundView?.frame = frame
        }
    }
    
    
    /**
    Used in Topic and Post cells
    */
    func timeAndLocationAttributedString(baseObject: Base) -> NSAttributedString {
        
        func dateToString(theDate: NSDate?) -> String {
            
            var result = ""
            if let date = theDate {
                
                let dateFormatter = NSDateFormatter()
                let daysFromNow = abs(date.daysFromNow())
                
                switch daysFromNow {
                    
                case 0:
                    dateFormatter.dateFormat = "h:mm a"
                    result = dateFormatter.stringFromDate(date)
                    
                case 1:
                    dateFormatter.dateFormat = "h:mm a"
                    result = "YESTERDAY " + dateFormatter.stringFromDate(date)
                    
                case 2...6:
                    dateFormatter.dateFormat = "eeee h:mm a"
                    result = dateFormatter.stringFromDate(date)
                    
                default:
                    dateFormatter.dateStyle = .MediumStyle
                    result = dateFormatter.stringFromDate(date)
                }
            }
            
            return result.uppercaseString
        }
        
        
        func relativeDistanceString(kilometers: CLLocationDistance) -> String {
            
            if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
                if usesMetric {
                    return String(NSString(format: "%.1f km away", kilometers))
                }
            }
            
            let convertedDistance = kilometers * 0.6214
            return String(NSString(format: "%.1f mi away", convertedDistance))
        }
        
        
        var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(11)
        
        var darkAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor()]
        darkAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(11)
        
        let s1 = NSMutableAttributedString(string: dateToString(baseObject.timestamp), attributes: darkAttributes)
        
        var locationText = String()
        if baseObject.hasLocation {
            
            locationText += "  |  "
            
            if let metersAway = LocationManager.sharedInstance.distanceFromCurrentLocation(latitude: baseObject.latitude!.doubleValue, longitude: baseObject.longitude!.doubleValue) {
                
                let distance = metersAway / 1000
                
                if distance < 1.0 {
                    locationText += "Nearby"
                }
                else if distance < 15.0 {
                    locationText += relativeDistanceString(distance)
                }
                else {
                    
                    if baseObject.hasLocationName {
                        locationText += baseObject.locationName!
                    }
                    else {
                        locationText += relativeDistanceString(distance)
                    }
                }
            }
            
            locationText = locationText.uppercaseString
        }
        
        let s2 = NSAttributedString(string: locationText, attributes: normalAttributes)
        s1.appendAttributedString(s2)
        return s1
    }
}

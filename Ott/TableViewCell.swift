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
        innerContentContainer?.clipsToBounds = true
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
                result = "yesterday " + dateFormatter.stringFromDate(date)
                
            case 2...6:
                dateFormatter.dateFormat = "eeee h:mm a"
                result = dateFormatter.stringFromDate(date)
                
            default:
                dateFormatter.dateStyle = .MediumStyle
                result = dateFormatter.stringFromDate(date)
            }
        }
        
        return result
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
    
    
    private let normalAttributes : [String : AnyObject] = {
        
        let color = UIColor.blackColor().colorWithAlphaComponent(0.5)
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        return [NSForegroundColorAttributeName : color, NSFontAttributeName: font]
        }()
    
    
    private let strongAttributes : [String : AnyObject] = {
        
        let color = UIColor.blackColor().colorWithAlphaComponent(0.7)
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        return [NSForegroundColorAttributeName : color, NSFontAttributeName: font]
        }()
    
    
    private let separatorAttributes : [String : AnyObject] = {
        
        let color = UIColor.blackColor()
        let font = UIFont.boldSystemFontOfSize(11)
        return [NSForegroundColorAttributeName : color, NSFontAttributeName: font]
        }()
    
    
    func timeAndLocationAttributedString(authoredObject: AuthoredObject) -> NSAttributedString {
        
        let s = NSMutableAttributedString(string: "", attributes: normalAttributes)
//        let s = NSMutableAttributedString(string: "created ", attributes: normalAttributes)
        
        let s1 = NSAttributedString(string: dateToString(authoredObject.createdAt), attributes: strongAttributes)
        
        s.appendAttributedString(s1)
        
        let s2 = NSAttributedString(string: " \u{00b7} ", attributes: separatorAttributes)
        s.appendAttributedString(s2)
        
        var locationText = ""
        
        if let location = authoredObject.location {
            
            if let metersAway = LocationManager.sharedInstance.distanceFromCurrentLocation(location) {
                
                let distance = metersAway / 1000
                
                if distance < 1.0 {
                    locationText += "nearby"
                }
                else if distance < 15.0 {
                    locationText += relativeDistanceString(distance)
                }
                else {
                    
                    if let locationName = authoredObject.locationName {
                        locationText += locationName
                    }
                    else {
                        locationText += relativeDistanceString(distance)
                    }
                }
            }
        }
        
        let s3 = NSAttributedString(string: locationText, attributes: strongAttributes)
        s.appendAttributedString(s3)
        return s
    }
    
    
    func updatedTimeAndLocationAttributedString(topic: Topic) -> NSAttributedString {
        
        if topic.numberOfPosts == 0 {
            return timeAndLocationAttributedString(topic)
        }
        
        let s = NSMutableAttributedString(string: "updated ", attributes: normalAttributes)
        
        let s1 = NSAttributedString(string: dateToString(topic.updatedAt), attributes: strongAttributes)
        
        s.appendAttributedString(s1)
        
        let s2 = NSAttributedString(string: " \u{00b7} ", attributes: separatorAttributes)
        s.appendAttributedString(s2)
        
        var locationText = ""
        
        if let lastPostLocation = topic.lastPostLocation {
            
            if let metersAway = LocationManager.sharedInstance.distanceFromCurrentLocation(lastPostLocation) {
                
                let distance = metersAway / 1000
                
                if distance < 1.0 {
                    locationText += "nearby"
                }
                else if distance < 15.0 {
                    locationText += relativeDistanceString(distance)
                }
                else {
                    
                    if let locationName = topic.lastPostLocationName {
                        locationText += locationName
                    }
                    else {
                        locationText += relativeDistanceString(distance)
                    }
                }
            }
        }
        
        let s3 = NSAttributedString(string: locationText, attributes: strongAttributes)
        s.appendAttributedString(s3)
        return s
    }
    
}

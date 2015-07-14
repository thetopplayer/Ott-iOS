//
//  TopicMasterTableViewCell.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreLocation

class TopicMasterTableViewCell: TableViewCell {

    @IBOutlet var topBar: UIView!
    @IBOutlet var topBarLabel: UILabel!
    @IBOutlet var statusBar: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var topicImageView: UIImageView?
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        topBar.backgroundColor = UIColor.whiteColor()
        topBar.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        statusBar.backgroundColor = UIColor.clearColor()
        
        topicImageView?.contentMode = .ScaleAspectFill
        topicImageView?.clipsToBounds = true
        
        selectionStyle = .None
    }

    
    private func updateContents() {
        
        if let topic = displayedTopic {
            
            topBarLabel.attributedText = timeAndLocationAttributedString(topic)
            
            ratingLabel.text = topic.ratingToText()
            ratingLabel.textColor = topic.ratingToColor()
            nameLabel.text = topic.name!
            if topic.comment != nil {
                commentLabel.text = topic.comment!
            }
            else {
                commentLabel.text = ""
            }
            
            statusLabel.attributedText = attributedDescription(topic)
            topicImageView?.image = topic.image
        }
    }
    
    
    
    private func timeAndLocationAttributedString(topic: Topic) -> NSAttributedString {
        
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
        
        let darkAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor()]
        
        let s1 = NSMutableAttributedString(string: dateToString(topic.timestamp), attributes: darkAttributes)
        
        var locationText = String()
        if topic.hasLocation {
            
            locationText += "  |  "
            
            if let metersAway = LocationManager.sharedInstance.distanceFromCurrentLocation(latitude: topic.latitude!.doubleValue, longitude: topic.longitude!.doubleValue) {
                
                let distance = metersAway / 1000
                
                if distance < 1.0 {
                    locationText += "Nearby"
                }
                else if distance < 15.0 {
                    locationText += relativeDistanceString(distance)
                }
                else {
                    
                    if topic.hasLocationName {
                        locationText += topic.locationName!
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

    
    private func attributedDescription(topic: Topic) -> NSAttributedString {
        
        var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(12)
        
        var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
        
        let s1 = NSMutableAttributedString(string: "\(topic.numberOfPosts.integerValue)", attributes: boldAttributes)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        let p = topic.numberOfPosts.integerValue == 1 ? " post " : " posts "
        let s2 = NSAttributedString(string: p + "since creation by ", attributes: normalAttributes)
        let authorName = topic.author.name != nil ? topic.author.name! : "Anonymous"
        let s3 = NSAttributedString(string: authorName, attributes: boldAttributes)
        
        s1.appendAttributedString(s2)
        s1.appendAttributedString(s3)
        return s1
    }
    
}

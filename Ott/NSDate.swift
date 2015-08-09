//
//  NSDate.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation

extension NSDate {
    
    private func unitsFromNow(unit: NSCalendarUnit) -> Int {
        
        let todayComponents = NSCalendar.currentCalendar().components(unit, fromDate: NSDate())
        let selfComponents = NSCalendar.currentCalendar().components(unit, fromDate: self)
        
        var result: Int
        switch unit {
            
        case NSCalendarUnit.Minute:
            result = todayComponents.minute - selfComponents.minute
            
        case NSCalendarUnit.Day:
            result = todayComponents.day - selfComponents.day
            
        case NSCalendarUnit.Month:
            result = todayComponents.month - selfComponents.month
            
        case NSCalendarUnit.Year:
            result = todayComponents.year - selfComponents.year
            
        default:
            NSLog("Not coded to handle calendar unit")
            assert(false)
            result = 0
        }
        
        return result
    }
    
    
    func daysFromNow() -> Int {
        
        return unitsFromNow(.Day)
    }
    
    
    func minutesFromNow(absolute absolute: Bool = false) -> Int {
        
        return unitsFromNow(.Minute)
    }
    
    
    func midnight() -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        let units = NSCalendarUnit.Year.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Day.rawValue
        let components = calendar.components(NSCalendarUnit(rawValue: units), fromDate: self)
        return calendar.dateFromComponents(components)!
    }
    
    
    func isToday() -> Bool {
        
        return NSCalendar.currentCalendar().isDateInToday(self)
    }
    
    
    func isSameDayAsDate(date: NSDate) -> Bool {
        
        return NSCalendar.currentCalendar().isDate(self, inSameDayAsDate: date)
    }
    
    
}
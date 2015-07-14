//
//  DataProtocols.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import UIKit
import CoreData


protocol Uploadable {
    
    func toDictionary() -> [String : String]
}


protocol Downloadable {
    
    func updateFromDictionary([String : String]) -> Void
}


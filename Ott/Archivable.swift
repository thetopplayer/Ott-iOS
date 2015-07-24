//
//  Archivable.swift
//  Ott
//
//  Created by Max on 7/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation

protocol Archivable {
    
    func saveNow()
    func saveWithCompletionBlock(completion: (success: Bool, error: NSError) -> Void)
}

//
//  TextView.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TextView: UITextView {
    
    var displayScrolling: Bool = true {
        didSet {
            self.showsVerticalScrollIndicator = displayScrolling
        }
    }
    
    override var contentOffset: CGPoint {
        set {
            if displayScrolling {
                super.contentOffset = newValue
            }
        }
        get {
            return super.contentOffset
        }
    }
}

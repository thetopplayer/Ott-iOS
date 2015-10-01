//
//  LabeledDotView.swift
//  Ott
//
//  Created by Max on 10/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LabeledDotView: DotView {

    private var label: UILabel = {
        
        let theLabel = UILabel(frame: CGRectZero)
        theLabel.textAlignment = NSTextAlignment.Center
        theLabel.textColor = UIColor.blackColor()
        theLabel.font = UIFont.systemFontOfSize(15)
        theLabel.adjustsFontSizeToFitWidth = true
        theLabel.minimumScaleFactor = 0.5
        
        return theLabel
        }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addSubview(label)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        addSubview(label)
    }
    
    
    var text: String? {
        
        set {
            label.text = newValue
        }
        
        get {
            return label.text
        }
    }
    
    
    var font: UIFont {
        
        set {
            label.font = newValue
        }
        
        get {
            return label.font
        }
    }
    
    
    var textColor: UIColor {
        
        set {
            label.textColor = newValue
        }
        
        get {
            return label.textColor
        }
    }

    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let insets = UIEdgeInsetsMake(2.0, 3.0, 3.0, 3.0)
        let frame = UIEdgeInsetsInsetRect(bounds, insets)
        label.frame = frame
    }
}

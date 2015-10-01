//
//  DotView.swift
//  Ott
//
//  Created by Max on 10/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class DotView: UIView {
    
    var fillColor: UIColor = UIColor.clearColor() {
        
        didSet {
            setNeedsDisplay()
        }
    }

    
    var borderColor: UIColor = UIColor.grayColor() {
        
        didSet {
            setNeedsDisplay()
        }
    }
    

    var borderWidth = CGFloat(1.0) {
        
        didSet {
            setNeedsDisplay()
        }
    }
    

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
    
    convenience init(frame: CGRect, fillColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) {
        
        self.init(frame: frame)
        
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    
    override func drawRect(rect: CGRect) {
        
        let dotRect: CGRect = CGRectMake(borderWidth, borderWidth, bounds.size.width - (2 * borderWidth), bounds.size.height - (2 * borderWidth))
        
        let path = UIBezierPath(ovalInRect: dotRect)
        fillColor.setFill()
        path.fill()
        borderColor.setStroke()
        path.stroke()
    }
}

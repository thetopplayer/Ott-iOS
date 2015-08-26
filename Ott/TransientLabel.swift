//
//  TransientLabel.swift
//  Ott
//
//  Created by Max on 8/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TransientLabel: UILabel {

    enum AnimationStyle {
        case Fade, FadeUp
    }
    
    
    convenience init(message: String, animationStyle: AnimationStyle = .FadeUp) {
        
        self.init(frame: CGRectMake(0, 0, 120, 32))
        
        self.layer.cornerRadius = 12.0
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.tint().colorWithAlphaComponent(0.8)
        self.textColor = UIColor.whiteColor()
        self.text = message
        self.textAlignment = NSTextAlignment.Center
        
        self.animationStyle = animationStyle
    }
    
    
    private var animationStyle = AnimationStyle.FadeUp
    private var completionBlock: (() -> Void)?
    private var completionTimer: NSTimer?
    
    func display(inView superView: UIView, completion: ( () -> Void)? ) {
        
        completionBlock = completion
        self.alpha = 0.0
        
        let index = superView.subviews.count == 0 ? 0 : superView.subviews.count - 1
        superView.insertSubview(self, atIndex: index)
        self.center = superView.center
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.alpha = 1.0
            }) { (_) -> Void in
                
                self.completionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "_hideLabel:", userInfo: nil, repeats: false)
        }
    }
    
    
    func _hideLabel(timer: NSTimer?) {
        
        let duration = animationStyle == .Fade ? 0.25 : 0.5
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.alpha = 0.0
            
            if self.animationStyle == .FadeUp {
                self.center = CGPointMake((self.superview?.center.x)!, -16)
            }
            
            }) { (_) -> Void in
                self.removeFromSuperview()
                self.completionBlock?()
        }
    }
    
    
    func abortDisplay() {
        
        self.removeFromSuperview()
        completionTimer?.invalidate()
    }
}

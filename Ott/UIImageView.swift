//
//  UIImageView.swift
//  Ott
//
//  Created by Max on 8/28/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageWithFade(image: UIImage?, duration: NSTimeInterval = 0.25) {
        
        UIView.transitionWithView(self,
            duration: duration,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: { self.image = image },
            completion: nil)
    }
    
    
    func indicateOK(ok: Bool) {
        
        let okImage = UIImage(named: "tick")
        let errImage = UIImage(named: "multiply")
        
        self.hidden = false
        
        if ok {
            self.tintColor = UIColor.fern()
            self.image = okImage
        }
        else {
            self.tintColor = UIColor.redColor()
            self.image = errImage
        }
    }
}

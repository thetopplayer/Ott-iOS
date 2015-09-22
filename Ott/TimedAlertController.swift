//
//  TimedAlertController.swift
//  Ott
//
//  Created by Max on 9/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TimedAlertController: UIAlertController {

    var duration: NSTimeInterval = 2.0
    var completion: (() -> Void)?
    
    func handleTimerAction(timer: NSTimer) {
        
        dismissViewControllerAnimated(true, completion: completion)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "handleTimerAction:", userInfo: nil, repeats: false)
    }
}

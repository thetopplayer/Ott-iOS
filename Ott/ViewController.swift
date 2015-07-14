//
//  ViewController.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    static var _operationQueue: OperationQueue = {
        return OperationQueue()
    }()
    
    
    func operationQueue() -> OperationQueue {
        return ViewController._operationQueue
    }
    
    
    private var _isVisible = false
    func isVisible() -> Bool {
        return _isVisible
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _isVisible = true
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        _isVisible = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

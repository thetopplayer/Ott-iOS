//
//  ViewController.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        return queue
        }()
    

    private var _isVisible = false
    func isVisible() -> Bool {
        return _isVisible
    }
    
    
    private var _willAppear = false
    func willAppear() -> Bool {
        return _willAppear
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _willAppear = true
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        _isVisible = true
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        _willAppear = false
        _isVisible = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    //MARK: - Display
    
    var defaultStatusMessage: String? {
        
        didSet {
            navigationItem.title = defaultStatusMessage
        }
    }
    
    
    func displayStatus(message: String? = nil) {
        
        if let message = message {
            navigationItem.title = message
        }
        else {
            navigationItem.title = defaultStatusMessage
        }
    }
}

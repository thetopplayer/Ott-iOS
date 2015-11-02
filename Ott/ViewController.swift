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
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        _isVisible = true
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
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
        
        if let messsage = message {
            navigationItem.title = messsage
        }
        else {
            navigationItem.title = defaultStatusMessage
        }
    }
}

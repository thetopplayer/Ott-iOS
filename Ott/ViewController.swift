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
    
    required init(coder aDecoder: NSCoder) {
        _viewWasLoaded = false
        super.init(coder: aDecoder)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        _viewWasLoaded = false
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    private var _viewWasLoaded = false
    func viewWasLoaded() -> Bool {
        return _viewWasLoaded
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        _viewWasLoaded = true
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

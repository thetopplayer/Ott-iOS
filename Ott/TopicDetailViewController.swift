//
//  TopicDetailViewController.swift
//  Ott
//
//  Created by Max on 7/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MapKit

class TopicDetailViewController: ViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    private let mapImageName = "paperMap"
    private let tableImageName = "list"
    
    
    //MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView()
        setupMapView()
        
//        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        refreshDisplay()
        displayView(type: .List)
    }
    
    
//    deinit {
//        endObservations()
//    }

    
    
    //MARK: - Actions
    
    @IBAction func handleToggleViewAction(sender: AnyObject) {
        
        if displayedType == .Map {
            displayedType = .List
        }
        else {
            displayedType = .Map
        }
    }
    
    
    @IBAction func handleDoneAction(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    
    //MARK: - Display
    
    private var _shouldRefreshDisplay = false
    func refreshDisplay() {
        
        if isViewLoaded() {
            
            _shouldRefreshDisplay = false
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        else {
            _shouldRefreshDisplay = true
        }
    }
    
    
    private enum ViewType {
        case Map, List
    }
    
    
    private var displayedType: ViewType? {
        
        didSet {
            
            if let type = displayedType {
                displayView(type: type)
            }
        }
    }

    
    private func displayView(type type: ViewType) {
        
        switch type {
            
        case .Map:
            
            navigationItem.rightBarButtonItem?.image = UIImage(named: tableImageName)
            
            mapView.alpha = 0
            mapView.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.mapView.alpha = 1.0
            })
            
        case .List:
            
            navigationItem.rightBarButtonItem?.image = UIImage(named: mapImageName)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.mapView.alpha = 0
                }, completion: { (_) -> Void in
                    self.mapView.hidden = true
            })
        }
    }
    
    
    
    //MARK: - Data
    
    lazy var managedObjectContext = {
        return DataManager.sharedInstance.managedObjectContext
        }()
    
    
    private var _myTopic: Topic?
    var myTopic: Topic? {
        
        set {
            
            if let t = newValue {
                _myTopic = t.instance(inContext: managedObjectContext) as? Topic
            }
            else {
                _myTopic = nil
            }
            
            refreshDisplay()
        }
        
        get {
            return _myTopic;
        }
    }
    
    
    var posts: [Post]? {
        
        if let posts = myTopic?.posts {
            return Array(posts)
        }
        
        return nil
    }
    
    
    
    //MARK: - TableView
    
    private let cellNibName = "PostDetailTableViewCell"
    private let cellIdentifier = "postCell"
    private let cellHeight = CGFloat(44)
    
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.background()
        tableView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: cellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let number = posts?.count {
            return number
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! PostDetailTableViewCell
        
        cell.displayedPost = posts![indexPath.row]
        return cell
    }
    
    
    
    //MARK: - MapView
    
    private func setupMapView() {
        
        mapView.delegate = self
    }
}

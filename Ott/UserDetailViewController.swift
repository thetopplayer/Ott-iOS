//
//  UserDetailViewController.swift
//  Ott
//
//  Created by Max on 9/23/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UserDetailViewController: TableViewController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        initializeView()
        startObservations()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        endObservations()
    }
    
    
    //MARK: - Display
    
    enum ExitMethod {
        case Back, Dismiss
    }
    var exitMethod = ExitMethod.Back
    

    private var didInitializeView = false
    private func initializeView() {
        
        func showDoneButton() {
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "handleDoneAction:")
            navigationItem.leftBarButtonItem = doneButton
        }
        
        
        func showBackButton() {
            
            let button = UIButton(frame: CGRectMake(0, 0, 80, 32))
            button.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 0)
            button.contentHorizontalAlignment = .Left
            let backImage = UIImage(named: "halfArrowLeft")
            button.setImage(backImage, forState: UIControlState.Normal)
            
            let title = presentingViewController?.title
            button.setTitle(title, forState: UIControlState.Normal)
            button.setTitleColor(UIColor.tint(), forState: UIControlState.Normal)
            button.addTarget(self, action: "handleDoneAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let backButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = backButton
        }

        
        guard let user = user else {
            return
        }
        
        if didInitializeView == false {
            
            navigationItem.title = user.handle
            
            if exitMethod == .Back {
                showBackButton()
            }
            else if exitMethod == .Dismiss {
                showDoneButton()
            }
            
            didInitializeView = true
        }
    }
    

    //MARK: - Data
    
    var user: User? {
        
        didSet {
            didInitializeView = false
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func handleDoneAction(sender: AnyObject) {
        
        if exitMethod == .Back {
            navigationController?.popViewControllerAnimated(true)
        }
        else if exitMethod == .Dismiss {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    
    //MARK: - TableView
    
    private func setupTableView() {
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.background()
        tableView.showsHorizontalScrollIndicator = false
        
//        let nib = UINib(nibName: cellNibName, bundle: nil)
//        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
//        
//        let nib1 = UINib(nibName: imageCellNibName, bundle: nil)
//        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellIdentifier)
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
//        let theTopic = displayedTopics[indexPath.row]
//        
//        let identifier = theTopic.hasImage() ? imageCellIdentifier: cellIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as! TopicMasterTableViewCell
//        
//        cell.displayedTopic = theTopic
        return cell
    }

    
    
    //MARK: - Observations and Delegate Methods
    
    private func startObservations() {
        
    }
    
    
    private func endObservations() {
        
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

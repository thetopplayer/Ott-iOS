//
//  HomeViewController.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData


class HomeViewController: ViewController, NavigatorToTopicCreation {

    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var handleTextLabel: UILabel!
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var summaryTextLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var topicTableViewController: TopicMasterViewController
    let tableHeaderNibName = "HomeTableHeaderView"
    let headerReuseName = "headerView"
    let headerViewHeight = CGFloat(50)


    //MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        
        topicTableViewController = TopicMasterViewController()
        
        super.init(coder: aDecoder)
        addChildViewController(topicTableViewController)
    }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        myUser = Author.user(inContext: managedObjectContext)

        view.backgroundColor = UIColor.background()

        userContainerView.backgroundColor = UIColor.whiteColor()
        userContainerView.addBorder()
        userContainerView.addShadow()
        
        avatarImageView.addRoundedBorder()
        summaryContainerView.backgroundColor = UIColor.whiteColor()
        summaryContainerView.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        
        topicTableViewController.fetchPredicate = NSPredicate(format: "author = %@", myUser!)
        topicTableViewController.tableView = tableView
        topicTableViewController.setHeaderView(nibName: tableHeaderNibName, reuseIdentifier: headerReuseName, height: headerViewHeight)
        
        topicTableViewController.viewDidLoad()
        
        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        topicTableViewController.update()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }

    
    override func didReceiveMemoryWarning() {
 
        super.didReceiveMemoryWarning()
     }
    
    
    deinit {
        endObservations()
    }

    
    
    //MARK: - Data
    
    private var myUser: Author? {
        
        didSet {
            updateDisplayedInformation()
        }
    }
    
    
    var managedObjectContext: NSManagedObjectContext = {
        
        return DataManager.sharedInstance.managedObjectContext
        }()
    
    
    
    
    //MARK: - Display
    
    private func updateDisplayedInformation() {
        
        if let theUser = myUser {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.nameTextLabel.text = theUser.name
                self.handleTextLabel.text = theUser.handle
                self.summaryTextLabel.attributedText = self.attributedUserDetails(theUser)
            })
        }
    }
    
    
    private func attributedUserDetails(user: Author) -> NSAttributedString {
        
        var numberAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor()]
        numberAttributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 15)
        
        let s1 = NSMutableAttributedString(string: "\(user.numberOfTopics.integerValue)", attributes: numberAttributes)
        
        var textAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        textAttributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Regular", size: 12)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        var s2: NSAttributedString
        let t = user.numberOfTopics.integerValue == 1 ? " TOPIC  -  " : " TOPICS  -  "
        s2 = NSAttributedString(string: t, attributes: textAttributes)
        
        let s3 = NSMutableAttributedString(string: "\(user.numberOfPosts.integerValue)", attributes: numberAttributes)
        
        var s4: NSAttributedString
        let p = user.numberOfTopics.integerValue == 1 ? " POSTS" : " POSTS"
        s4 = NSAttributedString(string: p, attributes: textAttributes)
        s3.appendAttributedString(s4)
        
        s1.appendAttributedString(s2)
        s1.appendAttributedString(s3)
        return s1
    }

    
    
    //MARK: -  Observations {
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUpdateUserNotification:", name: DataManager.Notification.DidUpdateUser, object: nil)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    func handleDidUpdateUserNotification(notification: NSNotification) {
        
        // refetch to update info
        myUser = nil
        myUser = Author.user(inContext: managedObjectContext)
    }
    
    
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    
    
    
    //MARK: - NavigatorToTopicCreation
    
    @IBAction func presentTopicCreationViewController(sender: AnyObject) {
        
        let segueToCreationIdentifier = "segueToTopicCreation"
        
        if LocationManager.sharedInstance.permissionGranted {
            performSegueWithIdentifier(segueToCreationIdentifier, sender: nil)
        }
        else {
            LocationManager.sharedInstance.requestPermission({ (granted) -> Void in
                if granted {
                    self.performSegueWithIdentifier(segueToCreationIdentifier, sender: nil)
                }
            })
        }
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        let segueToScanIdentifier = "segueToScan"
        
        if LocationManager.sharedInstance.permissionGranted {
            performSegueWithIdentifier(segueToScanIdentifier, sender: nil)
        }
        else {
            LocationManager.sharedInstance.requestPermission({ (granted) -> Void in
                if granted {
                    self.performSegueWithIdentifier(segueToScanIdentifier, sender: nil)
                }
            })
        }
    }

}

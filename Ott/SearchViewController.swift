//
//  SearchViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class SearchViewController: TopicMasterViewController, UISearchBarDelegate {
    
    
    var searchBar: UISearchBar?
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        searchBar = {
            
            let width = navigationController!.navigationBar.frame.size.width
            let height = navigationController!.navigationBar.frame.size.width
            let searchFrame = CGRectMake(0, 0, width, height)
            let bar = UISearchBar(frame: searchFrame)
            
            bar.delegate = self
            bar.barTintColor = UIColor.blackColor()
            bar.translucent = true
            return bar
            }()
        
        navigationItem.titleView = searchBar
        showCreateButton()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        if tableView.numberOfSections == 0 {
            searchBar?.becomeFirstResponder()            
        }
    }
    

    
    //MARK: - Search
    
    private func showCreateButton() {
        
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.rightBarButtonItem = createButton
    }
    
    
    private func showCancelButton() {
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelSearch:")
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    
    @IBAction func cancelSearch(sender: AnyObject?) {
        
        searchBar!.resignFirstResponder()
        showCreateButton()
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.showCancelButton()
            self.reloadTableView(withTopics: [Topic]())
        }
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        guard let query = searchBar.text else {
            return
        }
        
        guard query.length > 0 else {
            return
        }
        
        displayStatus(.Fetching)
        
        let fetchOperation = FetchSearchedTopicsOperation(searchPhrase: query) { (fetchResults, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let topics = fetchResults as? [Topic] {
                    self.reloadTableView(withTopics: topics)
                }
                self.displayStatus()
                
                if let error = error {
                    self.presentOKAlertWithError(error, messagePreamble: "Error retrieving search results.", actionHandler: nil)
                }
           }
        }
        
        FetchQueue.sharedInstance.addOperation(fetchOperation)
        searchBar.resignFirstResponder()
    }
    
    
    
    //MARK: - TableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        presentTopicDetailViewController(withTopic: selection)
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        presentTopicCreationViewController()
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentTopicScanViewController()
        }
    }
    
    
}


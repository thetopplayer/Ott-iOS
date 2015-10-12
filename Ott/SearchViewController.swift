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
            bar.translucent = false
            return bar
            }()
        
        navigationItem.titleView = searchBar
        showCreateButton()
        
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
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
        
        showCancelButton()
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        
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


//
//  DataManager.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class DataManager {
    
    static var sharedInstance: DataManager = {
        return DataManager()
        }()
    
    
    private init() {
        startObservations()
    }

    
    deinit {
        endObservations()
    }
    
    
    //MARK: - Timer Notification
    
//    static let saveNotificationTimer = NSTimer.schedul
    
    
    
    
    
    
    //MARK: - Observations and Notifications
    
    struct Notification {
        static let DidCreateTopic = "didCreateTopic"
        static let DidCreatePost = "didCreatePost"
        static let DidUpdateUser = "didUpdateUser"
        static let DidUpdateData = "didUpdateTopics"
        static let DidFetchTopic = "didFetchTopic"
    }
    
    struct Key {
        static let IdentifierKey = "identifier"
    }
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    @objc func handleDidBecomeActiveNotification(notification: NSNotification) {
        
//        updateUser(withHandle: userHandle)
    }
    
    
    
    //MARK: - User
   
    /*
    private var _userHandle: String?
    var userHandle: String? {
        
        if userHasBeenCreated {
            return _userHandle
        }
        return nil
    }
    
    
    private var _userHasBeenCreated: Bool?
    var userHasBeenCreated: Bool {
        
        if _userHasBeenCreated == nil {
            
            _userHasBeenCreated = false
            
            let fetchRequest = NSFetchRequest(entityName: "Author")
            fetchRequest.predicate = NSPredicate(format: "isUser = true")
            
            let context = backgroundManagedObjectContext
            context.performBlockAndWait { () -> Void in
                
                do {
                    let results = try context.executeFetchRequest(fetchRequest)
                    if results.count > 0 {
                        
                        if let user = results[0] as? Author {
                            
                            self._userHandle = user.identifier
                            self._userHasBeenCreated = true
                        }
                    }
                }
                catch {
                    abort()
                }
            }
        }
        
        return _userHasBeenCreated!
    }
    
    
    /**
    meant to be used primarily to update the current user's info, particularly the lastContentIdentifier, which is used to generate identifiers for topics and tags
    */
    
    func updateUser(withHandle handle: String?) {
        
        if let handle = handle {
            
            NSLog("updating user with identifier = %@", handle)
        }
        
    }
    */
    
    
    //MARK: - Data
    
    /**
        fetches trending topics from server, updates MOC in background, and posts notification when done
    */
    func fetchTrendingTopics() {
        
    }
    
    
    func fetchLocalTopics() {
        
    }
    
    
//    func upload(object: Uploadable) {
//        
//        NSLog("uploading object...")
//        save()
//    }
    
    
    private var _cancelFetchTopic = false
    func fetchTopic(withIdentifier identifier: String, completion: (TopicObject?) -> Void) {
        
        sleep(2)
        
        let fetchedTopic: TopicObject? = nil
        
        _cancelFetchTopic = false
        if _cancelFetchTopic == false {
            completion(fetchedTopic)
        }
    }
    
    
    func cancelFetchTopic() {
        _cancelFetchTopic = true
    }

}

//
//  DataManager.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData

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
    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "net.senisa.Ott" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("OttDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Ott.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = coordinator
        return moc
        }()
    
    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.persistentStoreCoordinator = coordinator
        return moc
        }()
    
    
    func save() {
        
        managedObjectContext.saveContext()
        backgroundManagedObjectContext.saveContext()
    }
    
    
    
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidSaveContextNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil)
        
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
    

    func containsUser(objects: Set<NSManagedObject>?) -> Bool {
        
        var foundUser = false
        if let theObjects = objects {
            searchLoop: for object in theObjects {
                if let author = object as? Author {
                    if author.isUser.boolValue {
                        foundUser = true
                        break searchLoop
                    }
                }
            }
        }
        
        return foundUser
    }

    
    @objc func handleDidSaveContextNotification(notification: NSNotification) {
        
        if let theObject = notification.object as? NSManagedObjectContext {
            
            if theObject.parentContext == managedObjectContext {
                managedObjectContext.saveContext()
            }
            else if theObject == managedObjectContext {
                
                if containsUser(notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.DidUpdateUser, object: self)
                }
                
            }
        }
    }
    
    
    @objc func handleDidBecomeActiveNotification(notification: NSNotification) {
        
        updateUser(withHandle: userHandle)
    }
    
    
    
    //MARK: - User
    
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
    
    
    
    //MARK: - Data
    
    /**
        fetches trending topics from server, updates MOC in background, and posts notification when done
    */
    func fetchTrendingTopics() {
        
    }
    
    
    func fetchLocalTopics() {
        
    }
    
    
    func upload(object: Uploadable) {
        
        NSLog("uploading object...")
        save()
    }
    
    
    private var _cancelFetchTopic = false
    func fetchTopic(withIdentifier identifier: String, completion: (Topic?) -> Void) {
        
        sleep(2)
        
        let fetchedTopic: Topic? = nil
        
        _cancelFetchTopic = false
        if _cancelFetchTopic == false {
            completion(fetchedTopic)
        }
    }
    
    
    func cancelFetchTopic() {
        _cancelFetchTopic = true
    }

}

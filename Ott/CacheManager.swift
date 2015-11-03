//
//  CacheManager.swift
//  Ott
//
//  Created by Max on 10/2/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation
import SystemConfiguration

class CacheManager {

    struct PinNames {
        static let UserPosts = "userPosts"
        static let UserTopics = "userTopics"
        static let FollowedByUser = "userFollows"
    }
    
    static let sharedInstance = CacheManager()
    
    
    //MARK: - Lifecycle
    
    func start() {
        
        didUpdateCurrentUserCaches = false
        
        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(reachability, &flags) != false {

            if flags.contains(.Reachable) {
                updateCurrentUserCaches()
            }
        }
    }
    
    
    func stop() {
        
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
    }
    
    
    let reachability: SCNetworkReachability = {
        
        let hostName = "https://api.parse.com".UTF8String
        let ref = SCNetworkReachabilityCreateWithName(nil, hostName)!
        
        func callback(reachabilityRef: SCNetworkReachability, flags: SCNetworkReachabilityFlags, context: UnsafeMutablePointer<Void>) -> Void {
            
            print("reachability did change")
            
            if flags.contains(.Reachable) {
                CacheManager.sharedInstance.updateCurrentUserCaches()
            }
        }
        
        SCNetworkReachabilitySetCallback(ref, callback, nil)
        return ref
        }()
    
    
    
    //MARK: - Fetching
    
    private var didUpdateAuthoredTopics = false
    private var didUpdateAuthoredPosts = false
    private var didUpdateAuthoredFollowees = false
    
    var didUpdateCurrentUserCaches: Bool {
        
        get {
            return didUpdateAuthoredTopics && didUpdateAuthoredPosts && didUpdateAuthoredFollowees
        }
        
        set {
            didUpdateAuthoredTopics = newValue
            didUpdateAuthoredPosts = newValue
            didUpdateAuthoredFollowees = newValue
        }
    }
    
    
    func updateCurrentUserCaches() {
        
        if didUpdateCurrentUserCaches {
            return
        }
        
        if userIsLoggedIn() {
            
            print("updating user caches")
            
            currentUser().fetchIfNeededInBackground()
            updateCachedAuthoredTopics()
            updateCachedAuthoredPosts()
            updateCachedFollowees()
            didUpdateCurrentUserCaches = true
        }
    }
    
    
    private func updateCachedAuthoredTopics() {
        
        let now = NSDate()
        let lastUpdatedTopics = Globals.sharedInstance.lastUpdatedAuthoredTopics
        let fetchTopicsOperation = FetchCurrentUserAuthoredTopicsOperation(dataSource: .Server, offset: 0, updatedSince: lastUpdatedTopics, completion: {
            (_, error) in
            
            if error == nil {
                Globals.sharedInstance.lastUpdatedAuthoredTopics = now
                self.didUpdateAuthoredTopics = true
            }
        })
        
        fetchTopicsOperation.fetchAll = true
        MaintenanceQueue.sharedInstance.addOperation(fetchTopicsOperation)
    }
    
    
    private func updateCachedAuthoredPosts() {
        
        let now = NSDate()
        let lastUpdatedPosts = Globals.sharedInstance.lastUpdatedAuthoredPosts
        let fetchPostsOperation = FetchCurrentUserAuthoredPostsOperation(dataSource: .Server, offset: 0, updatedSince: lastUpdatedPosts, completion: {
            (_, error) in
            
            if error == nil {
                Globals.sharedInstance.lastUpdatedAuthoredPosts = now
                self.didUpdateAuthoredPosts = true
            }
        })
        
        fetchPostsOperation.fetchAll = true
        MaintenanceQueue.sharedInstance.addOperation(fetchPostsOperation)
    }
    
    
    private func updateCachedFollowees() {
        
        let now = NSDate()
        let lastUpdated = Globals.sharedInstance.lastUpdatedFollowees
        let fetchOperation = FetchCurrentUserFolloweesOperation(dataSource: .Server, updatedSince: lastUpdated, completion: {
            (_, error) in
            
            if error == nil {
                Globals.sharedInstance.lastUpdatedFollowees = now
                self.didUpdateAuthoredFollowees = true
            }
        })

        fetchOperation.fetchAll = true
        MaintenanceQueue.sharedInstance.addOperation(fetchOperation)
    }
    
    
    
    //MARK: - Cleanup
    
    func unpinAllData() {
        
        FetchCurrentUserAuthoredTopicsOperation.purgeCache()
        FetchCurrentUserAuthoredPostsOperation.purgeCache()
        FetchCurrentUserFolloweesOperation.purgeCache()
    }
    
    
    private func cleanupAuthoredTopicsCache() {
        
    }
    
    
    private func cleanupAuthoredPostsCache() {
        
    }
    
    
    private func cleanupFollowedUsersCache() {
        
    }
    
}

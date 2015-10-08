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

    static let sharedInstance = CacheManager()
    
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
    
    
    var didUpdateCurrentUserCaches = false
    
    func updateCurrentUserCaches() {
        
        if didUpdateCurrentUserCaches {
            return
        }
        
        if userIsLoggedIn() {
            
            print("updating user caches")
            
            currentUser().fetchIfNeededInBackground()
            updateCachedAuthoredObjects()
            didUpdateCurrentUserCaches = true
        }
    }
    
    
    private func updateCachedAuthoredObjects() {
        
        let now = NSDate()
        let lastUpdatedPosts = Globals.sharedInstance.lastUpdatedAuthoredPosts
        let fetchPostsOperation = FetchCurrentUserAuthoredPostsOperation(dataSource: .Server, updatedSince: lastUpdatedPosts, completion: {
            (_, error) in
            
            if error == nil {
                Globals.sharedInstance.lastUpdatedAuthoredPosts = now
            }
        })
        
        let lastUpdatedTopics = Globals.sharedInstance.lastUpdatedAuthoredTopics
        let fetchTopicsOperation = FetchCurrentUserAuthoredTopicsOperation(dataSource: .Server, updatedSince: lastUpdatedTopics, completion: {
            (_, error) in
            
            if error == nil {
                Globals.sharedInstance.lastUpdatedAuthoredTopics = now
            }
        })
        
        // because topics are flagged as having been posted to by the current user based on the locally cached posts, get posts first
        fetchTopicsOperation.addDependency(fetchPostsOperation)
        
        MaintenanceQueue.sharedInstance.addOperation(fetchPostsOperation)
        MaintenanceQueue.sharedInstance.addOperation(fetchTopicsOperation)
    }

    
    private func cleanupLocalTopicsCache() {
        
    }
    
    
    private func cleanupFollowedUsersTopicsCache() {
        
    }
    
    
    private func cleanupAuthoredTopicsCache() {
        
    }
    
    
    private func cleanupAuthoredPostsCache() {
        
    }
    
    
    private func cleanupFollowedUsersCache() {
        
    }
    
}

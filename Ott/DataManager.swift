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
    
    
    
    //MARK: - Data
    
    var arrangedLocalTopics: [Topic]
    var arrangedTrendingTopics: [Topic]
    

    
    
    //MARK: - Observations and Notifications
    
    struct Notification {
        static let DidCreateTopic = "didCreateTopic"
        static let DidCreatePost = "didCreatePost"
        static let DidUpdateUser = "didUpdateUser"
        static let DidUpdateData = "didUpdateTopics"
        static let DidFetchTopic = "didFetchTopic"
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
    
    
    
    
    //MARK: - Data
    

}

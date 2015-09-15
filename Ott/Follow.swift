//
//  Follow.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


extension DataKeys {
    
    static var Follower: String {
        return "follower"
    }
    
    static var FollowerName: String {
        return "followerName"
    }
    
    static var FollowerHandle: String {
        return "followerHandle"
    }
    
    static var FollowerBio: String {
        return "followerBio"
    }
    
    static var FollowerAvatar: String {
        return "followerAvatar"
    }
    
    static var Followee: String {
        return "followee"
    }
    
    static var FolloweeName: String {
        return "FolloweeName"
    }
    
    static var FolloweeHandle: String {
        return "followeeHandle"
    }
    
    static var FolloweeBio: String {
        return "followeeBio"
    }
    
    static var FolloweeAvatar: String {
        return "followeeAvatar"
    }
}


class Follow: BaseObject, PFSubclassing {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String {
        return "Follow"
    }
    
    
//    /** Use this to create */
//    class func createRelationBetween(follower follower: User, following followee: User) -> Follow {
//        
//        let follow = Follow()
//        follow.setFollower(follower)
//        follow.setFollowee(followee)
//        
//        return follow
//    }
    
    
    //MARK: - Attributes
    
    @NSManaged var followerName: String?
    @NSManaged var followerHandle: String?
    @NSManaged var followerBio: String?
    
    func setFollower(follower: User) {
        
        self[DataKeys.Follower] = follower
        followerName = follower.name
        followerHandle = follower.handle
        followerBio = follower.bio
        
        if follower.hasImage() {
            follower.getImage(completion: { (success, image) -> Void in
                if success && image != nil {
                    self.setImage(image, forKey: DataKeys.FollowerAvatar)
                }
            })
        }
    }
    
    @NSManaged var followeeName: String?
    @NSManaged var followeeHandle: String?
    @NSManaged var followeeBio: String?
    
    func setFollowee(followee: User) {
        
        self[DataKeys.Followee] = followee
        followeeName = followee.name
        followeeHandle = followee.handle
        followeeBio = followee.bio
        
        if followee.hasImage() {
            followee.getImage(completion: { (success, image) -> Void in
                if success && image != nil {
                    self.setImage(image, forKey: DataKeys.FolloweeAvatar)
                }
            })
        }
    }
}

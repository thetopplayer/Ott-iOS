//
//  Author.swift
//  Ott
//
//  Created by Max on 7/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

protocol Author: class, Archivable {
    
    var username: String? {get set}
    var handle: String? {get set}
    var phoneNumber: String? {get set}
    var numberOfPosts: Int? {get}
    var numberOfTopics: Int? {get}
    
    func addPost<T: Post>(post: T)
    func removePost<T: Post>(post: T)
    func getPosts<T: Post>(completion: (success: Bool, posts: [T]?) -> Void) -> Void
 
    func didPostToTopic<T: Topic>(topic: T) -> Bool
    
    func addTopic<T: Topic>(topic: T)
    func removeTopic<T: Topic>(topic: T)
    func getTopics<T: Topic>(completion: (success: Bool, posts: [T]?) -> Void) -> Void
    
    func setAvatar(image: UIImage?) -> Void
    func getAvatar(completion: (success: Bool, image: UIImage?) -> Void) -> Void
}

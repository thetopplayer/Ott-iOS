//
//  Topic.swift
//  Ott
//
//  Created by Max on 7/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

protocol Topic: Creation {

    var name: String? {get set}
    var numberOfPosts: Int? {get}
    var averageRating: Int? {get}

    func addPost<T: Post>(post: T)
    func removePost<T: Post>(post: T)
    func getPosts<T: Post>(completion: (success: Bool, posts: [T]?) -> Void) -> Void
}

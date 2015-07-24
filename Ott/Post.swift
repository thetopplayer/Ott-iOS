//
//  Post.swift
//  Ott
//
//  Created by Max on 7/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

protocol Post: Creation {
    
    func setTopic<T: Topic>(topic: T) -> Void
    var topicName: String? {get set}
}

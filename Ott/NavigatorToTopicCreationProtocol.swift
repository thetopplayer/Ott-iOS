//
//  NavigatorToTopicCreationProtocol.swift
//  Ott
//
//  Created by Max on 7/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

/**
    Protocol implemented by view controllers that provide access to topic creation
    and scanning view controllers
*/

protocol NavigatorToTopicCreationProtocol {
    
    func presentTopicCreationViewController(sender: AnyObject) -> Void
    func presentTopicScanViewController(sender: AnyObject) -> Void
}

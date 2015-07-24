//
//  Creation.swift
//  Ott
//
//  Created by Max on 7/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MapKit

protocol Creation: Base, MKAnnotation {

    var authorName: String? {get set}
    var authorHandle: String? {get set}
    var authorAvatarURL: String? {get set}
    var rating: Rating? {get set}
    
    func getAuthorAvatar(completion: (success: Bool, image: UIImage?) -> Void) -> Void
}




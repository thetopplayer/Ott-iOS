//
//  Base.swift
//  Ott
//
//  Created by Max on 7/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

protocol Base: class, Archivable {
    
    var identifier: String? {get}
    var createdAt: NSDate? {get}
    var updatedAt: NSDate? {get}
    var comment: String? {get set}
    var location: CLLocationCoordinate2D? {get set}
    var locationName: String? {get set}
    var hasImage: Bool {get}
    
    func setImage(image: UIImage?, size: CGSize?, var quality: CGFloat) -> Void
    func getImage(completion: (success: Bool, image: UIImage?) -> Void) -> Void
}

//
//  TableView.swift
//  Ott
//
//  Created by Max on 10/30/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TableView: UITableView {

    private func setup() {
    
        separatorStyle = .SingleLine
        separatorColor = UIColor.separator()
        backgroundColor = UIColor.background()
        showsHorizontalScrollIndicator = false
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
    }
    
    
    lazy var refreshControl: UIRefreshControl = {
        
        let rc = UIRefreshControl()
        rc.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        return rc
    }()
    
    
    func useRefreshControl() {
        insertSubview(refreshControl, atIndex: 0)
    }
}

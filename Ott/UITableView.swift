//
//  UITableView.swift
//  Ott
//
//  Created by Max on 8/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

extension UITableView {

    
    func adjustTableViewInsets(withBottom bottom: CGFloat, var top: CGFloat = 64) {
        
        if let navHeight = topmostViewController()?.navigationController?.navigationBar.frame.size.height {
            top = navHeight + 20
        }
        
        contentInset = UIEdgeInsetsMake(top, 0, bottom, 0)
    }
    
    
    func scrollToBottom(animated animated: Bool = false) {
        
        guard numberOfSections > 0 else {
            return
        }
        
        let rowCount = numberOfRowsInSection(numberOfSections - 1)
        if rowCount == 0 {
            return
        }
        
        let ip = NSIndexPath(forRow: rowCount - 1, inSection: numberOfSections - 1)
        scrollToRowAtIndexPath(ip, atScrollPosition: .Bottom, animated: animated)
    }
    
    
    
    //MARK: - Data
    
    func updateByReplacing<T: Hashable> (inout datasourceData datasourceData: [T], withData updatedData: [T], inSection section: Int, sortingArraysWith isOrderedBefore: (T, T) -> Bool) {
        
        _update(datasourceData: &datasourceData, withData: updatedData, replacingdatasourceData: true, inSection: section, sortingArraysWith: isOrderedBefore)
    }
    
    
    func updateByAddingTo<T: Hashable> (inout datasourceData datasourceData: [T], withData updatedData: [T], inSection section: Int, sortingArraysWith isOrderedBefore: (T, T) -> Bool) {
        
        _update(datasourceData: &datasourceData, withData: updatedData, replacingdatasourceData: false, inSection: section, sortingArraysWith: isOrderedBefore)
    }
    

    private func _update<T: Hashable> (inout datasourceData datasourceData: [T], withData updatedData: [T], replacingdatasourceData: Bool, inSection section: Int, sortingArraysWith isOrderedBefore: (T, T) -> Bool) {
        
        let existingSet = Set(datasourceData)
        let updatedSet = Set(updatedData)
        
        // deletions (anything in existing datasource that's not in the updated data)
        let removedObjects = existingSet.subtract(updatedSet)
        var indexPathsForRemoval = [NSIndexPath]()
        if replacingdatasourceData {
            
            for topic in removedObjects {
                let row = datasourceData.indexOf(topic)!
                let ip = NSIndexPath(forRow: row, inSection: section)
                indexPathsForRemoval.append(ip)
            }
        }
        
        // updates (anyting in the updated data that's in the existing set)
        let updatedObjects = updatedSet.intersect(existingSet)
        var indexPathsForUpdate = [NSIndexPath]()
        for var index = 0; index < datasourceData.count; index++ {
            if updatedObjects.contains(datasourceData[index]) {
                let ip = NSIndexPath(forRow: index, inSection: section)
                indexPathsForUpdate.append(ip)
            }
        }
        
        let addedObjects = updatedSet.subtract(existingSet)
        let finalData: [T] = {
            
            var finalSet = addedObjects.union(updatedObjects)
            
            // add back removed objects if we aren't deleting any
            if replacingdatasourceData == false {
                finalSet = finalSet.union(removedObjects)
            }
            
            let sortedArray = Array(finalSet).sort(isOrderedBefore)
            return sortedArray
            
            }()
        
        // update the datasource
        datasourceData = finalData
        
        // insertions (anything in the updated data that's not in the existing data)
        var indexPathsForInsert = [NSIndexPath]()
        for var index = 0; index < finalData.count; index++ {
            if addedObjects.contains(finalData[index]) {
                let ip = NSIndexPath(forRow: index, inSection: section)
                indexPathsForInsert.append(ip)
            }
        }
        
        self.beginUpdates()
        
        if replacingdatasourceData && indexPathsForRemoval.count > 0 {
            self.deleteRowsAtIndexPaths(indexPathsForRemoval, withRowAnimation: .Automatic)
        }
        
        if indexPathsForUpdate.count > 0 {
            self.reloadRowsAtIndexPaths(indexPathsForUpdate, withRowAnimation: .None)
        }
        
        if indexPathsForInsert.count > 0 {
            self.insertRowsAtIndexPaths(indexPathsForInsert, withRowAnimation: .Automatic)
        }
        
        self.endUpdates()
    }
    
}

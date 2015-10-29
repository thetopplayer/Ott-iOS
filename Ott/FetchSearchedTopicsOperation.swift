//
//  FetchSearchedTopicsOperation.swift
//  Ott
//
//  Created by Max on 10/16/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


// NOTE;  probably better to use a cloud function so that the search algorighm is consistent with the one used to parse topics on upload

class FetchSearchedTopicsOperation: FetchTopicsOperation {

    init(searchPhrase: String, completion: FetchCompletionBlock?) {
        
        let query: PFQuery = {
            
            let lowercaseString = searchPhrase.lowercaseString
            let cleanedString = lowercaseString.stringByRemovingCharactersInString(".,;:\"")
            let wordArray = cleanedString.componentsSeparatedByString(" ")
            
            let query = Topic.query()!
            query.whereKey(DataKeys.SearchWords, containsAllObjectsInArray: wordArray)
            return query
        }()
        
        super.init(dataSource: .Server, query: query, completion: completion)
    }
}




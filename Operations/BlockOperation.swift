/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This code shows how to create a simple subclass of Operation.
*/

import Foundation

/// A closure type that takes a closure as its parameter.
typealias OperationBlock = (Void -> Void) -> Void

/// A sublcass of `Operation` to execute a closure.
class BlockOperation: Operation {
    private let block: OperationBlock?
    
    /**
        The designated initializer.
        
        - parameter block: The closure to run when the operation executes. This 
            closure will be run on an arbitrary queue. The parameter passed to the
            block **MUST** be invoked by your code, or else the `BlockOperation`
            will never finish executing. If this parameter is `nil`, the operation
            will immediately finish.
    */
    init(block: OperationBlock? = nil) {
        self.block = block
        super.init()
    }
    
    /**
        A convenience initializer to execute a block on the main queue.
        
        - parameter queueBlock: The block to execute on the global default queue. Note
            that this block does not have a "continuation" block to execute (unlike
            the designated initializer). The operation will be automatically ended 
            after the `queueBlock` is executed.
    */
    convenience init(queueBlock: dispatch_block_t) {
        self.init(block: { continuation in
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                queueBlock()
                continuation()
            }
        })
    }
    
    override func execute() {
        guard let block = block else {
            finish()
            return
        }
        
        block {
            self.finish()
        }
    }
}

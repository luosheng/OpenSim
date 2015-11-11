//
//  CancelBlocks.swift
//  Smooth
//
//  Created by Evgenii Rtishchev on 16/02/15.
//  Copyright (c) 2015 Evgenii Rtishchev. All rights reserved.
//

import Foundation

typealias dispatch_cancelable_block_t = (cancel:Bool) -> (Void)

func dispatch_block_t(delay:Double, block:dispatch_block_t?) -> dispatch_cancelable_block_t? {
    if (block == nil) {
        return nil
    }
    var originalBlock:dispatch_block_t? = block!
    var cancelableBlock:dispatch_cancelable_block_t? = nil
    let delayBlock:dispatch_cancelable_block_t = {(cancel:Bool) -> Void in
        if (!cancel) && (originalBlock != nil) {
            dispatch_async(dispatch_get_main_queue(), originalBlock!)
        }
        cancelableBlock = nil
        originalBlock = nil
    }
    cancelableBlock = delayBlock
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        if let cancelableBlock = cancelableBlock {
            cancelableBlock(cancel: false)
        }
    }
    return cancelableBlock
}

func dispatch_cancel_block_t(block:dispatch_cancelable_block_t?) {
    if let block = block {
        block(cancel: true)
    }
}
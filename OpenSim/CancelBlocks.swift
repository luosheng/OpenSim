//
//  CancelBlocks.swift
//  Smooth
//
//  Created by Evgenii Rtishchev on 16/02/15.
//  Copyright (c) 2015 Evgenii Rtishchev. All rights reserved.
//

import Foundation

typealias dispatch_cancelable_block_t = (cancelled: Bool) -> ()

func dispatch_block_t(delay: NSTimeInterval, block: dispatch_block_t) -> dispatch_cancelable_block_t {
    var cancelableBlock: dispatch_cancelable_block_t? = nil
    let delayBlock: dispatch_cancelable_block_t = { (cancelled: Bool) in
        if (!cancelled) {
            dispatch_async(dispatch_get_main_queue(), block)
        }
        cancelableBlock = nil
    }
    cancelableBlock = delayBlock
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        if let cancelableBlock = cancelableBlock {
            cancelableBlock(cancelled: false)
        }
    }
    return delayBlock
}

func dispatch_cancel_block_t(block: dispatch_cancelable_block_t?) {
    if let block = block {
        block(cancelled: true)
    }
}
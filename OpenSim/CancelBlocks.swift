//
//  CancelBlocks.swift
//  Smooth
//
//  Created by Evgenii Rtishchev on 16/02/15.
//  Copyright (c) 2015 Evgenii Rtishchev. All rights reserved.
//

import Foundation

typealias dispatch_cancelable_block_t = (cancelled: Bool) -> ()

func dispatch_block_t(_ delay: TimeInterval, block: () -> Void) -> dispatch_cancelable_block_t {
    var cancelableBlock: dispatch_cancelable_block_t? = nil
    let delayBlock: dispatch_cancelable_block_t = { (cancelled: Bool) in
        if (!cancelled) {
            DispatchQueue.main.async(execute: block)
        }
        cancelableBlock = nil
    }
    cancelableBlock = delayBlock
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        if let cancelableBlock = cancelableBlock {
            cancelableBlock(cancelled: false)
        }
    }
    return delayBlock
}

func dispatch_cancel_block_t(_ block: dispatch_cancelable_block_t?) {
    if let block = block {
        block(cancelled: true)
    }
}

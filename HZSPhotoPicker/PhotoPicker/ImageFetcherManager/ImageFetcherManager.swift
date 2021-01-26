//
//  ImageFetcherManager.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2021/1/23.
//  Copyright © 2021 黄中山. All rights reserved.
//

import UIKit
import Photos

class ImageFetcherManager {
    
    static let `default` = ImageFetcherManager()
    
    let queue: OperationQueue
    let cache: PoMemoryCache<String, UIImage>
    
    
    init(queue: OperationQueue? = nil, cache: PoMemoryCache<String, UIImage>? = nil) {
        self.queue = queue ?? OperationQueue()
        self.queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
        self.cache = cache ?? PoMemoryCache<String, UIImage>()
    }
    
    @discardableResult
    func fetch(with asset: PHAsset, targetSize: CGSize, completion: ((UIImage?, PHAsset) -> Void)? = nil) -> ImageFetcherOperation {
        let operation = ImageFetcherOperation(asset: asset, targetSize: targetSize, cache: cache, completion: completion)
        queue.addOperation(operation)
        return operation
    }
}

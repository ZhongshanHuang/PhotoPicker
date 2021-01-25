//
//  ImageFetcherOperation.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2021/1/23.
//  Copyright © 2021 黄中山. All rights reserved.
//

import UIKit
import Photos

class ImageFetcherOperation: Operation {
    let asset: PHAsset
    let targetSize: CGSize
    let cache: PoMemoryCache<String, UIImage>?
    let completion: ((UIImage?, PHAsset) -> Void)?
    
    private var memoryCache: PoMemoryCache<String, UIImage> {
        return cache ?? ImageFetcherManager.default.cache
    }
    
    private let _lock: NSRecursiveLock = NSRecursiveLock()
    private var isStarted: Bool = false
    private var imageRequestID: PHImageRequestID = 0

    private var _executing: Bool = false
    override var isExecuting: Bool {
        set {
            _lock.lock()
            if newValue != _executing {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
            _lock.unlock()
        }
        get {
            _lock.lock()
            let value = _executing
            _lock.unlock()
            return value
        }
    }
    
    private var _finished: Bool = false
    override var isFinished: Bool {
        set {
            _lock.lock()
            if newValue != _finished {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
            _lock.unlock()
        }
        get {
            _lock.lock()
            let value = _finished
            _lock.unlock()
            return value
        }
    }
    
    private var _cancelled: Bool = false
    override var isCancelled: Bool {
        set {
            _lock.lock()
            if newValue != _cancelled {
                willChangeValue(forKey: "isCancelled")
                _cancelled = newValue
                didChangeValue(forKey: "isCancelled")
            }
            _lock.unlock()
        }
        get {
            _lock.lock()
            let value = _cancelled
            _lock.unlock()
            return value
        }
    }
    
    override var isConcurrent: Bool {
        return true
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == "isExecuting" || key == "isFinished" || key == "isCancelled" {
            return false
        }
        return super.automaticallyNotifiesObservers(forKey: key)
    }
    
    init(asset: PHAsset, targetSize: CGSize, cache: PoMemoryCache<String, UIImage>? = nil, completion: ((UIImage?, PHAsset) -> Void)?) {
        self.asset = asset
        self.targetSize = targetSize
        self.cache = cache
        self.completion = completion
    }

    
    override func start() {
        autoreleasepool { () -> Void in
            _lock.lock()
            isStarted = true
            if isCancelled {
                cancelOperation()
                isFinished = true
            } else if isReady && !isFinished && !isExecuting {
                isExecuting = true
                startOperation()
            }
            
            _lock.unlock()
        }
    }
    
    override func cancel() {
        _lock.lock()
        if !isCancelled {
            super.cancel()
            isCancelled = true
            if isExecuting {
                isExecuting = false
                cancelOperation()
            }
            if isStarted {
                isFinished = true
            }
        }
        _lock.unlock()
    }
    
    // MARK: - Helper
    
    private func startOperation() {
        if isCancelled { return }
        
        imageRequestID = ImagePickerManager.shared.loadImageData(with: asset) { (data, _) in
            guard let data = data else {
                self.completion?(nil, self.asset);
                self.finishOperation()
                return
            }
            
            let type = PoImageDetectType(data: data as NSData)
            var image: PoImage?
            if type == .gif {
                image = PoImage(data: data)
            } else {
                if let cgImage = downsampleToCgImage(imageData: data, to: self.targetSize, scale: UIScreen.main.scale) {
                    image = PoImage(cgImage: cgImage)
                }
            }
            if let image = image {
                self.memoryCache.setObject(image, forKey: self.asset.localIdentifier + "\(self.targetSize)", cost: image.cost)
            }
            self.completion?(image, self.asset)
            self.finishOperation()
        }
    }
    
    private func finishOperation() {
        isExecuting = false
        isFinished = true
    }
    
    private func cancelOperation() {
        PHImageManager.default().cancelImageRequest(imageRequestID)
    }
}

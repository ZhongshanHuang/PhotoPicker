//
//  UIImageView+extension.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/7/5.
//  Copyright © 2020 黄中山. All rights reserved.
//

import UIKit
import Photos

private var kImageSetterKey: Void?

extension UIImageView {
    
    func setImage(with asset: PHAsset, toSize size: CGSize, completion: ((UIImage?) -> Void)? = nil) {
        var imageSetter: _PoImageSetter! = objc_getAssociatedObject(self, &kImageSetterKey) as? _PoImageSetter
        if imageSetter == nil {
            imageSetter = _PoImageSetter()
            objc_setAssociatedObject(self, &kImageSetterKey, imageSetter, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        let sentinel = imageSetter.cancel()
        
        Dispatch_sync_on_main_queue {
            if let cachedImage = ImageFetcherManager.default.cache.object(forKey: asset.localIdentifier + "\(size)") {
                self.image = cachedImage
                completion?(cachedImage)
                return
            }
            
            let closure = { [weak self] (image: UIImage?, phAsset: PHAsset) in
                guard let wself = self else { completion?(nil); return }
                DispatchQueue.main.async {
                    wself.image = image
                    completion?(image)
                }
            }
            imageSetter.loadImage(with: asset, targetSize: size, sentinel: sentinel, completion: closure)
        }
    }
    
}

private class _PoImageSetter {
    fileprivate var _sentinel = PoSentinel()
    private var imageRequestID: PHImageRequestID = 0
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    private(set) var operation: ImageFetcherOperation?
    
    @discardableResult
    func cancel() -> Int {
        let sentinel: Int
        semaphore.wait()
        operation?.cancel()
        operation = nil
        sentinel = _sentinel.increase() + 1
        semaphore.signal()
        return sentinel
    }
    
    func loadImage(with asset: PHAsset, targetSize: CGSize, sentinel: Int, completion: @escaping (UIImage?, PHAsset) -> Void) {
        if sentinel != _sentinel.value() {
            completion(nil, asset)
            return
        }
        
        operation = ImageFetcherManager.default.fetch(with: asset, targetSize: targetSize, completion: completion)
        
        semaphore.wait()
        if sentinel != _sentinel.value() {
            cancel()
        }
        semaphore.signal()
    }
    
    deinit {
        operation?.cancel()
    }
}

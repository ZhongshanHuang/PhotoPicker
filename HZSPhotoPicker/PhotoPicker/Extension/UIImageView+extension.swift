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
        
        imageSetter.cancel()
        image = nil
        
        if let cachedImage = ImageFetcherManager.default.cache.object(forKey: asset.localIdentifier + "\(size)") {
            self.image = cachedImage
            completion?(cachedImage)
            return
        }
        
        let closure = { [weak self] (image: UIImage?, phAsset: PHAsset) in
            guard let wself = self, let image = image else {
                completion?(nil)
                return
            }
            DispatchQueue.main.async {
                wself.image = image
                completion?(image)
            }
        }
        imageSetter.loadImage(with: asset, targetSize: size, completion: closure)
    }
    
}

private class _PoImageSetter {
    private let _sentinel = PoSentinel()
    private var imageRequestID: PHImageRequestID = 0
    private(set) var operation: ImageFetcherOperation?
    
    func cancel() {
        operation?.cancel()
        operation = nil
        _sentinel.increase()
    }
    
    func loadImage(with asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?, PHAsset) -> Void) {
        operation = ImageFetcherManager.default.fetch(with: asset, targetSize: targetSize, sentinel: _sentinel, sentinelValue: _sentinel.value, completion: completion)
    }
    
    deinit {
        operation?.cancel()
    }
}

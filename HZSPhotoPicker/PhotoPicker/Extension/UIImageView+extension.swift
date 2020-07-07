//
//  UIImageView+extension.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/7/5.
//  Copyright © 2020 黄中山. All rights reserved.
//

import UIKit
import Photos.PHAsset

private var kImageSetterKey: Void?

extension UIImageView {
    
    func setImage(with asset: PHAsset, toSize size: CGSize, completion: ((UIImage?) -> Void)? = nil) {
        var imageSetter: _PoImageSetter! = objc_getAssociatedObject(self, &kImageSetterKey) as? _PoImageSetter
        if imageSetter == nil {
            imageSetter = _PoImageSetter()
            objc_setAssociatedObject(self, &kImageSetterKey, imageSetter, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        let sentinel = imageSetter.cancel(with: asset)
        
        if let imageCache = ImagePickerManager.shared.cache.object(forKey: asset.localIdentifier + "\(size)") {
            self.image = imageCache
            completion?(imageCache)
            return
        }
        
        if sentinel != imageSetter._sentinel.value() {
            completion?(nil)
            return
        }
        
        let closure = { [weak self] (image: UIImage?, phAsset: PHAsset) in
            guard let wself = self else { completion?(nil); return }
            wself.image = image
            completion?(image)
        }
        imageSetter.loadImage(with: asset, targetSize: size, sentinel: sentinel, completion: closure)
    }
    
}

private class _PoImageSetter {
    
    static let setterQueue = DispatchQueue(label: "_PoImageSetter", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
    
    fileprivate var _sentinel = PoSentinel()

    
    func cancel(with asset: PHAsset) -> Int {
        return _sentinel.increase() + 1
    }
    
    func loadImage(with asset: PHAsset, targetSize: CGSize, sentinel: Int, completion: @escaping (UIImage?, PHAsset) -> Void) {
        if sentinel != _sentinel.value() {
            completion(nil, asset)
            return
        }
        
        ImagePickerManager.shared.loadImageData(with: asset) { (data, _) in
            guard let data = data else { completion(nil, asset); return }
            
            _PoImageSetter.setterQueue.async {
                let image = downsample(imageData: data, to: targetSize, scale: UIScreen.main.scale)
                ImagePickerManager.shared.cache.setObject(image, forKey: asset.localIdentifier + "\(targetSize)", cost: image.cost)
                DispatchQueue.main.async {
                    if sentinel != self._sentinel.value() {
                        completion(nil, asset)
                        return
                    }
                    completion(image, asset)
                }
            }
            
        }
    }
    
}


private extension UIImage {
    var cost: Int {
        guard let cgImage = self.cgImage else { return 1 }
        let cost = cgImage.bytesPerRow * cgImage.height
        if cost == 0 { return 1 }
        return cost
    }
}


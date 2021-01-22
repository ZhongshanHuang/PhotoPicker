//
//  ImageDownsample.swift
//  KitDemo
//
//  Created by 黄中山 on 2019/11/12.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

// MARK: - downsample large images for display at smaller size

func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
    let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
    let downsampleOptions = [
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
    let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
    return UIImage(cgImage: cgImage)
}

func downsampleToCgImage(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> CGImage? {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
    let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
    let downsampleOptions = [
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
    return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
}


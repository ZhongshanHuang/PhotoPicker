//
//  UIImage+extension.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2021/1/23.
//  Copyright © 2021 黄中山. All rights reserved.
//

import UIKit

extension UIImage {
    var cost: Int {
        guard let cgImage = self.cgImage else { return 1 }
        let cost = cgImage.bytesPerRow * cgImage.height
        if cost == 0 { return 1 }
        return cost
    }
}

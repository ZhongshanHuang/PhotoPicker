//
//  UIDevice+extension.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/6/27.
//  Copyright © 2020 黄中山. All rights reserved.
//

import UIKit

extension UIDevice {
    
    /// 是否是iPhone X
    ///
    /// - Returns: 是否
    static func isIphoneX() -> Bool {
        guard #available(iOS 11.0, *) else {
            return false
        }
        
        return UIApplication.shared.windows[0].safeAreaInsets.bottom > 0
    }
    
    static var topSafeArea: CGFloat {
        if isIphoneX() { return 88 }
        return 64
    }
    
    static var bottomSafeArea: CGFloat {
        if isIphoneX() { return 83 }
        return 49
    }
    
}

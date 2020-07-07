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
    static var isIphoneX: Bool {
        guard #available(iOS 11.0, *) else {
            return false
        }
        
        return UIApplication.shared.windows[0].safeAreaInsets.bottom > 0
    }
    
    static var topSafeArea: CGFloat {
        if isIphoneX { return 88 }
        return 64
    }
    
    static var bottomSafeArea: CGFloat {
        if isIphoneX { return 83 }
        return 49
    }
    
    static var memoryTotal: Int64 {
        let mem = ProcessInfo.processInfo.physicalMemory
        return Int64(mem)
    }
    
    static var memoryFree: Int64 {
        let host_port = mach_host_self()
        var host_size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.size / MemoryLayout<integer_t>.size)
        var page_size: vm_size_t = 0
        var vm_stat: vm_statistics_data_t = vm_statistics_data_t()
        var kern: kern_return_t
        
        kern = host_page_size(host_port, &page_size)
        if kern != KERN_SUCCESS { return -1 }
        withUnsafeMutablePointer(to: &vm_stat) { (pt) -> Void in
            pt.withMemoryRebound(to: integer_t.self, capacity: Int(host_size), { (p) -> Void in
                kern = host_statistics(host_port, HOST_VM_INFO, p, &host_size)
            })
        }
        if kern != KERN_SUCCESS { return -1 }
        return Int64(vm_stat.free_count) * Int64(page_size)
    }
    
}

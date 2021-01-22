//
//  PhotoPickerBaseViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/6/29.
//  Copyright © 2020 黄中山. All rights reserved.
//

import UIKit

class PhotoPickerBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
    }
    
    
    deinit {
        debugPrint("☠️\(self)☠️")
    }

}

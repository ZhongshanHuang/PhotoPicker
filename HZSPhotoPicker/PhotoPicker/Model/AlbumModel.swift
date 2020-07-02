//
//  AlbumModel.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation
import Photos.PHFetchResult

struct AlbumModel {
    let name: String
    let fetchResult: PHFetchResult<PHAsset>
}

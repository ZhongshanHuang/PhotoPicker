//
//  ImagePickerController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos.PHAsset

@objc
protocol ImagePickerControllerDelegate: class {
    
    // 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的handle
    @objc
    optional func imagePickerController(_ picker: ImagePickerController, didFinishPickingPhotos photos: Array<UIImage>, isOriginal: Bool)
}

extension ImagePickerController {
    
    enum PickerType {
        case avatar // 头像选择器(可以裁剪)
        case selections // 照片选择器(可以多选)
    }
    
    enum CropBox {
        case size(CGSize)
        case ratio(Double)
    }
}

class ImagePickerController: UINavigationController {
    
    // MARK: - Properties
    
    let type: PickerType
    
    weak var pickerDelegate: ImagePickerControllerDelegate?
    
    /// 最多可以选择照片的数量
    let maxSelectableImagesCount: Int
    
    /// 裁剪框的大小
    let cropBox: CropBox
    
    /// MARK: - 相册展示外观
    ///
    /// 相册的列数
    let columnCount: Int
    
    /// 相册照片的间隙
    var margin: CGFloat = 2
    
    /// 按照修改时间的升序排序
    var sortAscendingByModificationDate: Bool {
        get { return ImagePickerManager.shared.sortAscendingByModificationDate }
        set { ImagePickerManager.shared.sortAscendingByModificationDate = newValue }
    }
    
    /// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图
    var allowPickingOriginalPhoto: Bool = false
    
    /// 默认为YES，如果设置为NO,用户将不能选择视频
    var allowPickingVideo = true
    
    /// 用户选中的图片数组
    var selectedModels: [IndexPath: AssetModel] = [:]
    
    // MARK: Initializer
    
    /// 相册选择器
    init(columnCount: Int = 4, maxSelectableImagesCount: Int = 9, delegate: ImagePickerControllerDelegate) {
        type = .selections
        self.cropBox = .size(.zero)
        self.pickerDelegate = delegate
        self.columnCount = columnCount
        self.maxSelectableImagesCount = maxSelectableImagesCount
        
        let pickVC = PhotoPickerViewController()
        super.init(rootViewController: pickVC)
    }
    
    /// 头像选择器
    init(cropBox: CropBox = .ratio(1), columnCount: Int = 4, delegate: ImagePickerControllerDelegate) {
        type = .avatar
        self.cropBox = cropBox
        self.pickerDelegate = delegate
        self.columnCount = columnCount
        self.maxSelectableImagesCount = 0
        
        let pickVC = PhotoPickerViewController()
        super.init(rootViewController: pickVC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        navigationBar.barStyle = .black
        navigationBar.barTintColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        navigationBar.tintColor = UIColor.white
    }
    
    deinit {
        // 清除cache
        ImagePickerManager.shared.cache.removeAllObjects()
    }
}


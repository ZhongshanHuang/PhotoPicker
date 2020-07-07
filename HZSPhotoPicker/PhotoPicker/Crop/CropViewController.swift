//
//  CropViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/6/24.
//  Copyright © 2020 黄中山. All rights reserved.
//

import UIKit

class CropViewController: PhotoPickerBaseViewController {

    var image: UIImage?
    var assetModel: AssetModel?
    
    override func loadView() {
        let cropBox = (navigationController as! ImagePickerController).cropBox
        view = CropView(cropBox: cropBox)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        loadData()
    }

    private func setupUI() {
        view.backgroundColor = .black
        
        let confirmBtn = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(handleConfirmAction))
        navigationItem.rightBarButtonItem = confirmBtn
    }
    
    private func loadData() {
        if image != nil {
            (view as! CropView).image = image
        } else if let model = assetModel {
            ImagePickerManager.shared.loadImage(with: model.asset, targetSize: UIScreen.main.bounds.size, completion: { (image, _, isDegraded) in
                if !isDegraded {
                    (self.view as! CropView).image = image
                }
            })
        }
    }
    
    @objc
    private func handleConfirmAction() {
        let picker = navigationController as! ImagePickerController
        let image = (view as! CropView).cropImage()
        picker.dismiss(animated: true) {
            picker.pickerDelegate?.imagePickerController?(picker, didFinishPickingPhotos: [image], isOriginal: false)
        }
    }
}

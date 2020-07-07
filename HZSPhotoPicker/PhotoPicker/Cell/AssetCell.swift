//
//  PhotoPickerCell.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/21.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos

class AssetCell: UICollectionViewCell {
    
    static let identifier = "AssetCell"
    
    // MARK: - Properties[public]
    var indexPath: IndexPath!
    var selectBlockHander: ((Int) -> Void)?
    var assetModel: AssetModel? {
        didSet {
            guard let model = assetModel else { return }
            
            imageView.image = nil
            self.assetModel = model
            
            selectBtn.isSelected = model.isSelected
            if model.type == .video {
                videoIcon.isHidden = false
                timeLabel.isHidden = false
                timeLabel.text = model.timeLength
            } else {
                videoIcon.isHidden = true
                timeLabel.isHidden = true
            }
            
            imageView.setImage(with: model.asset, toSize: bounds.size)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Selector
    
    /// 选中按钮点击方法
    @objc
    private func handleSelectAction(_ sender: UIButton) {
        let isSelected = sender.isSelected
        
        // 图片不能超过9张提示
        if !isSelected, imagePicker.selectedModels.count >= imagePicker.maxSelectableImagesCount {
            let alertVC = UIAlertController(title: "图片选择", message: "不能超过\(imagePicker.maxSelectableImagesCount)张图片", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "确认", style: .cancel, handler: nil)
            alertVC.addAction(cancel)
            imagePicker.present(alertVC, animated: true, completion: nil)
            return
        }
        
        sender.isSelected = !isSelected
        assetModel?.isSelected = sender.isSelected
        
        if sender.isSelected {
            imagePicker.selectedModels[indexPath] = assetModel
        } else {
            imagePicker.selectedModels.removeValue(forKey: indexPath)
        }
        
        selectBlockHander?(imagePicker.selectedModels.count)
    }
    
    // MARK: - Layout Subviews
    private func setupSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectBtn)
        contentView.addSubview(videoIcon)
        contentView.addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectBtn.frame = CGRect(x: bounds.width - 27, y: 0, width: 27, height: 27)
        imageView.frame = bounds
        videoIcon.frame = CGRect(x: 0, y: bounds.height - 16, width: 16, height: 16)
        timeLabel.frame = CGRect(x: videoIcon.frame.maxX + 5, y: videoIcon.frame.minY, width: bounds.width - videoIcon.frame.maxX - 5, height: videoIcon.frame.height)
    }

    
    // MARK: - Properties[private-lazy]
    lazy var selectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "photo_choose_def"), for: .normal)
        btn.setImage(UIImage(named: "photo_choose_sel"), for: .selected)
        btn.addTarget(self, action: #selector(handleSelectAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textColor = UIColor.white
        label.textAlignment = .right
        label.text = "00:00"
        return label
    }()
    
    private lazy var videoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "photo_video")
        return imageView
    }()
}


// MARK: - 获取 ImagePickerController
private extension AssetCell {
    
    var imagePicker: ImagePickerController! {
        var next = self.next
        while next != nil {
            if next is UIViewController {
                return (next as? UIViewController)?.navigationController as? ImagePickerController
            }
            next = next?.next
        }
        return nil
    }
}

//
//  AlbumCell.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/21.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {
    
    static let identifier = "AlbumCell"
    
    // MARK: - Properties
    
    var albumModel: AlbumModel? {
        didSet {
            guard let model = albumModel else { return }
            
            let nameAttributedStr = NSMutableAttributedString(string: model.name, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.black])
            let countAttributedStr = NSAttributedString(string: "  (\(model.fetchResult.count))", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.lightGray])
            nameAttributedStr.append(countAttributedStr)
            titleLabel.attributedText = nameAttributedStr
            
            ImagePickerManager.shared.loadPosterImage(with: model, targetSize: CGSize(width: 70, height: 70)) { (postImage) in
                self.posterImageView.image = postImage
            }
        }
    }
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.black
        label.textAlignment = .left
        return  label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleHeight = ceil(titleLabel.font.lineHeight)
        titleLabel.frame = CGRect(x: 80, y: (bounds.height - titleHeight) / 2, width: bounds.width - 70 - 50, height: titleHeight)
        posterImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
    }
    
}

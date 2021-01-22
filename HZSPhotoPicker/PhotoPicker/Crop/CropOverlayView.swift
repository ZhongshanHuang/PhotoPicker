//
//  CropOverlayView.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/6/24.
//  Copyright © 2020 黄中山. All rights reserved.
//

import UIKit

private let kCornerWidth: CGFloat = 20

class CropOverlayView: UIView {
    
    private lazy var outerLines: [UIView] = {
        return [createNewLine(), createNewLine(), createNewLine(), createNewLine()]
    }()
//    private lazy var topLeftLines: [UIView] = {
//        return [createNewLine(), createNewLine()]
//    }()
//    private lazy var bottomLeftLines: [UIView] = {
//        return [createNewLine(), createNewLine()]
//    }()
//    private lazy var bottomRightLines: [UIView] = {
//        return [createNewLine(), createNewLine()]
//    }()
//    private lazy var topRightLines: [UIView] = {
//        return [createNewLine(), createNewLine()]
//    }()
    private lazy var horizontalLines: [UIView] = {
        return [createNewLine(), createNewLine()]
    }()
    private lazy var verticalLines: [UIView] = {
        return [createNewLine(), createNewLine()]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override var frame: CGRect {
        didSet {
            layoutLines()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutLines()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        clipsToBounds = false
    }
    
    private func layoutLines() {
        let boundsSize = bounds.size
        
        // border
        for (idx, line) in outerLines.enumerated() {
            let frame: CGRect
            switch idx {
            case 0: // top
                frame = CGRect(x: 0, y: 0, width: boundsSize.width, height: 1)
            case 1: // right
                frame = CGRect(x: boundsSize.width - 1, y: 0, width: 1, height: boundsSize.height)
            case 2: // bottom
                frame = CGRect(x: 0, y: boundsSize.height - 1, width: boundsSize.width, height: 1)
            case 3: // left
                frame = CGRect(x: 0, y: 0, width: 1, height: boundsSize.height)
            default:
                frame = .zero
            }
            line.frame = frame
        }
        
        // corner
        // top left
//        topLeftLines[0].frame = CGRect(x: -3, y: -3, width: 3, height: kCornerWidth + 3)
//        topLeftLines[1].frame = CGRect(x: 0, y: -3, width: kCornerWidth, height: 3)
//
//        // top right
//        topRightLines[0].frame = CGRect(x: boundsSize.width, y: -3, width: 3, height: kCornerWidth + 3)
//        topRightLines[1].frame = CGRect(x: boundsSize.width - kCornerWidth, y: -3, width: kCornerWidth, height: 3)
//
//        // bottom right
//        bottomRightLines[0].frame = CGRect(x: boundsSize.width, y: boundsSize.height - kCornerWidth, width: 3, height: kCornerWidth + 3)
//        bottomRightLines[1].frame = CGRect(x: boundsSize.width - kCornerWidth, y: boundsSize.height, width: kCornerWidth, height: 3)
//
//        // bottom left
//        bottomLeftLines[0].frame = CGRect(x: -3, y: boundsSize.height - kCornerWidth, width: 3, height: kCornerWidth)
//        bottomLeftLines[1].frame = CGRect(x: -3, y: boundsSize.height, width: kCornerWidth + 3, height: 3)
        
        // grid lines - horizontal
        let thickness = 1 / UIScreen.main.scale
        var numberOfLines = horizontalLines.count
        var padding = (bounds.height - thickness * CGFloat(numberOfLines)) / CGFloat(numberOfLines + 1)
        for (idx, line) in horizontalLines.enumerated() {
            line.frame = CGRect(x: 0, y: (padding * CGFloat(idx + 1) + thickness * CGFloat(idx)), width: bounds.width, height: thickness)
        }
        
        // grid lines - vertical
        numberOfLines = verticalLines.count
        padding = (bounds.width - thickness * CGFloat(numberOfLines)) / CGFloat(numberOfLines + 1)
        for (idx, line) in verticalLines.enumerated() {
            line.frame = CGRect(x: padding * CGFloat(idx + 1) + thickness * CGFloat(idx), y: 0, width: thickness, height: bounds.height)
        }
    }
    
    private func createNewLine() -> UIView {
        let line = UIView()
        line.backgroundColor = .white
        addSubview(line)
        return line
    }
}


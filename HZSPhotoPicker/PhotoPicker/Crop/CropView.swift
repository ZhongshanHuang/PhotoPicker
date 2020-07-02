//
//  CropView.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/6/24.
//  Copyright © 2020 黄中山. All rights reserved.
//

import UIKit

enum CropStyle {
    case circular
    case rectangle
}

class CropView: UIView {
    
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            backgroundImageView.image = image
            foregroundImageView.image = image
            setPosition(accordingTo: image.size)
            matchForegroundContainerToGridOverLayView()
            alignmentFB()
        }
    }
    
    private(set) var cropStyle: CropStyle = .rectangle
    let cropBox: CGSize
    
    
    private lazy var scrollView: CropScrollView = {
        let scroll = CropScrollView()
        scroll.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scroll.alwaysBounceHorizontal = true
        scroll.alwaysBounceVertical = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.delegate = self
        if #available(iOS 13, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        }
        return scroll
    }()
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.minificationFilter = .trilinear
        return imageView
    }()
    
    private let foregroundContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    private let foregroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.minificationFilter = .trilinear
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private let gridOverlayView: UIView = CropOverlayView()
    
    
    func cropImage() -> UIImage {
        let format: UIGraphicsImageRendererFormat
        if #available(iOS 11, *) {
            format = .preferred()
        } else {
            format = .default()
        }
        
        let cropSize = foregroundContainer.frame.size
        let render = UIGraphicsImageRenderer(size: cropSize, format: format)
        return render.image { (renderContext) in
            foregroundContainer.drawHierarchy(in: CGRect(origin: .zero, size: cropSize), afterScreenUpdates: false)
        }
    }
    
    init(cropBox: CGSize) {
        self.cropBox = cropBox
        super.init(frame: .zero)
        setupUI()
    }
            
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.touchEvent = { [weak self] state in
            if state == .ended {
                self?.alignmentFB()
            }
        }
        addSubview(scrollView)
        
        scrollView.addSubview(backgroundImageView)
        
        foregroundContainer.frame.size = cropBox
        addSubview(foregroundContainer)
        
        foregroundContainer.addSubview(foregroundImageView)
        
        gridOverlayView.frame = foregroundContainer.frame
        gridOverlayView.isUserInteractionEnabled = false
        addSubview(gridOverlayView)
    }
    
    /// 根据图片大小设置imageView的大小，并且设置scrollView的contentInset，使imageView处在中间
    private func setPosition(accordingTo size: CGSize) {
        let w = scrollView.bounds.width
        let h = w * (size.height / size.width)
        
        let vertical = (scrollView.bounds.height - gridOverlayView.frame.height) / 2
        let horizontal = (scrollView.bounds.width - gridOverlayView.frame.width) / 2
        
        scrollView.contentSize = CGSize(width: w, height: h)
        
        if h < scrollView.bounds.height {
            // 计算内容距离中间的间距
            let centerInterval = (scrollView.bounds.height - h) / 2

            scrollView.contentInset = UIEdgeInsets(top: max(vertical, centerInterval), left: horizontal, bottom: vertical, right: horizontal)
            scrollView.setContentOffset(CGPoint(x: 0, y: -centerInterval), animated: false)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }
        
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        foregroundImageView.frame = CGRect(x: 0, y: 0, width: w, height: h)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gridOverlayView.center = center
    }
    
    private func alignmentFB() {
        foregroundImageView.frame = scrollView.convert(backgroundImageView.frame, to: foregroundContainer)
    }
    
    private func matchForegroundContainerToGridOverLayView() {
        foregroundContainer.frame = gridOverlayView.frame
    }
}

extension CropView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        alignmentFB()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 当scrollView缩放时，imageView的transform发生变化，会导致frame发生变化，但bounds不会改变，所以必须用frame计算
        let offsetX = (scrollView.bounds.width - backgroundImageView.frame.width) / 2
        let offsetY = (scrollView.bounds.height - backgroundImageView.frame.height) / 2

        scrollView.contentInset = UIEdgeInsets(top: (offsetY < 0 ? 0 : offsetY),
                                               left: (offsetX < 0 ? 0 : offsetX),
                                               bottom: 0,
                                               right: 0)
    }

}

private class CropScrollView: UIScrollView {
    
    enum TouchState {
        case began
        case moved
        case ended
        case cancelled
    }
    
    var touchEvent: ((TouchState) -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchEvent = touchEvent {
            touchEvent(.began)
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchEvent = touchEvent {
            touchEvent(.moved)
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchEvent = touchEvent {
            touchEvent(.ended)
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchEvent = touchEvent {
            touchEvent(.cancelled)
        }
        super.touchesCancelled(touches, with: event)
    }
    
}

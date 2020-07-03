//
//  PhotoPreviewViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/4/1.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos.PHAsset

class PhotoPreviewViewController: PhotoPickerBaseViewController {
    
    var assetModels: [AssetModel] = []
    /// 开始进入这个页面时应该显示的item索引
    var targetIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    /// 当前显示的item索引
    var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    /// 是否点击预览按钮进来的
    var isFromPreview = false
    
    private var isStatusHiden: Bool = true
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGestureRecognizer()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // collectionView
        let margin: CGFloat = 8
        var rect = view.bounds
        rect.size.width += margin
        
        collectionView = UICollectionView(frame: rect, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(collectionView)
        
        // delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // register cell
        collectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: PhotoPreviewCell.identifier)
        
        // flowLayout
        flowLayout.itemSize = collectionView.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        // topBar
        topBar.frame = CGRect(x: 0, y: isStatusHiden ? -UIDevice.topSafeArea : 0, width: view.bounds.width, height: UIDevice.topSafeArea)
        view.addSubview(topBar)
        
        let bottomPadding: CGFloat = 15
        
        // backBtn
        let backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(named: "navigation_back_white"), for: .normal)
        backBtn.addTarget(self, action: #selector(handleBackAction), for: .touchUpInside)
        backBtn.frame = CGRect(x: 8, y: topBar.bounds.height - 30 - bottomPadding, width: 60, height: 30)
        topBar.addSubview(backBtn)
        
        // selectBtn
        selectBtn.frame = CGRect(x: topBar.bounds.width - 27 - 8, y: topBar.bounds.height - 27 - bottomPadding, width: 27, height: 27)
        topBar.addSubview(selectBtn)
        
        // bottomBar
        bottomBar.frame = CGRect(x: 0, y: isStatusHiden ? view.bounds.height : view.bounds.height - UIDevice.bottomSafeArea, width: view.bounds.width, height: UIDevice.bottomSafeArea)
        view.addSubview(bottomBar)
        
        let topPadding: CGFloat = UIDevice.isIphoneX ? 15 : 10
        
        
        // originalBtn
        originalBtn.frame = CGRect(x: (bottomBar.bounds.width - 60)/2, y: topPadding, width: 60, height: 30)
        bottomBar.addSubview(originalBtn)
        
        // senderBtn
        senderBtn.frame = CGRect(x: bottomBar.bounds.width - 60 - 8, y: topPadding, width: 60, height: 30)
        bottomBar.addSubview(senderBtn)
    }
    
    private func addGestureRecognizer() {
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapGesture))
        view.addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        oneTap.require(toFail: doubleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(pan)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 滑动到指定的indexPath
        collectionView.scrollToItem(at: targetIndexPath, at: .left, animated: false)
        senderBtn.isEnabled = (imagePicker.selectedModels.count > 0)
        senderBtn.alpha = (senderBtn.isEnabled ? 1.0 : 0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTopAndBottomBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return isStatusHiden
    }
    
    // 隐藏状态栏时的动画
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - Selector
    
    /// GestureMethod
    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = abs(gesture.translation(in: view).y)
        let height = view!.bounds.size.height
        let percent = min(translation * 2 / height, 1)
        let point = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            collectionView.center = CGPoint(x: self.view.center.x + point.x, y: self.view.center.y + point.y)
            collectionView.transform = CGAffineTransform.identity.scaledBy(x: 1 - percent, y: 1 - percent)
            view.backgroundColor = UIColor.black.withAlphaComponent(1 - percent)
        case .cancelled, .ended:
            if percent > 0.2 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.35) {
                    self.collectionView.center = self.view.center
                    self.collectionView.transform = .identity
                    self.view.backgroundColor = .black
                }
            }
        default:
            break
        }
    }
    
    /// 显示
    @objc
    private func handleBackAction() {
        dismiss(animated: true, completion: nil)
    }
    
    /// 单击的时候显示或者隐藏bar
    @objc
    private func oneTapGesture() {
        setTopAndBottomBarHidden(!isStatusHiden, animated: true)
    }
    
    private func setTopAndBottomBarHidden(_ hidden: Bool, animated: Bool) {
        if hidden == isStatusHiden { return }
        
        isStatusHiden.toggle()

        // 显示或者隐藏navigationBar
        if #available(iOS 9.0, *) {
            setNeedsStatusBarAppearanceUpdate()
        } else {
            UIApplication.shared.isStatusBarHidden = isStatusHiden
        }

        // 显示或者隐藏bottomBar
        UIView.animate(withDuration: animated ? 0.35 : 0) {
            self.topBar.frame.origin.y += (self.isStatusHiden ? -UIDevice.topSafeArea : UIDevice.topSafeArea)
            self.bottomBar.frame.origin.y += (self.isStatusHiden ? UIDevice.bottomSafeArea : -UIDevice.bottomSafeArea)
        }
    }
    
    /// 双击放大图片
    @objc
    private func doubleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let cell = collectionView.visibleCells.first as? PhotoPreviewCell else { return }
        let point = gesture.location(in: view)
        cell.scrollViewZoom(in: point)
    }
    
    /// 原图选项
    @objc
    private func handleOriginalAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    /// 发送按钮点击
    @objc
    private func handleSendAction(_ sender: UIButton) {
        let isOriginal = originalBtn.isSelected
        var selectImages: [UIImage] = []
        
        DispatchQueue.global(qos: .default).async {
            for (_, model) in self.imagePicker.selectedModels {
                self.group.enter()
                // 线程同步
                _ = self.semaphore.wait(wallTimeout: DispatchWallTime.distantFuture)
                ImagePickerManager.shared.loadPhoto(with: model.asset, isOriginal: isOriginal, completion: { (image, _, isDegraded) in
                    if !isDegraded, let image = image {
                        selectImages.append(image)
                        self.group.leave()
                        self.semaphore.signal()
                    }
                })
            }

        }
        group.wait()
        imagePicker.pickerDelegate?.imagePickerController?(imagePicker, didFinishPickingPhotos: selectImages, isOriginal: isOriginal)
    }
    
    /// 选中按钮
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
        
        // 切换状态
        sender.isSelected.toggle()
        let assetModel = assetModels[currentIndexPath.row]
        assetModel.isSelected = sender.isSelected
        
        if sender.isSelected {
            imagePicker.selectedModels[currentIndexPath] = assetModel
        } else {
            imagePicker.selectedModels.removeValue(forKey: currentIndexPath)
        }
    }
    
    // MARK: - Properties[private-lazy]
    
    private lazy var selectBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "photo_choose_def"), for: .normal)
        btn.setImage(UIImage(named: "photo_choose_sel"), for: .selected)
        btn.addTarget(self, action: #selector(handleSelectAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        return view
    }()

    
    private lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        return view
    }()
    
    private lazy var originalBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(handleOriginalAction(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle(" 原图", for: .normal)
        btn.setImage(UIImage(named: "photo_original_def"), for: .normal)
        btn.setImage(UIImage(named: "photo_original_sel"), for: .selected)
        btn.setTitleColor(UIColor.white, for: .normal)
        return btn
    }()
    
    private lazy var senderBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(handleSendAction(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitle("发送", for: .normal)
        btn.backgroundColor = UIColor.green
        btn.alpha = 0.5
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    private lazy var group: DispatchGroup = DispatchGroup()
    private lazy var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private var imagePicker: ImagePickerController {
        var nextRes: UIResponder? = next
        while nextRes != nil {
            if nextRes is UIViewController {
                break
            }
            nextRes = nextRes?.next
        }
        return nextRes as! ImagePickerController
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoPreviewViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPreviewCell.identifier, for: indexPath) as! PhotoPreviewCell
        cell.setAssetModel(assetModels[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoPreviewViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 重置scrollView的zoomScale
        (cell as! PhotoPreviewCell).resetScale()
        
        // 选中按钮的状态
        selectBtn.isSelected = assetModels[indexPath.row].isSelected
        
        // 当前显示cell的indexPath
        currentIndexPath = indexPath
    }
}

// MARK: - PhotoBrowserDismissDelegate

extension PhotoPreviewViewController: PhotoBrowserDismissDelegate {
    
    func imageViewFromDismiss() -> UIImageView {
        let image = (collectionView.visibleCells.first as? PhotoPreviewCell)?.imageView.image
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    func indexPathForDismiss() -> IndexPath {
        if isFromPreview {
            let cell = collectionView.visibleCells.first as! PhotoPreviewCell
            return imagePicker.selectedModels.first { (key, value) -> Bool in
                return cell.assetModel === value
            }!.key
        }
        return collectionView.indexPathsForVisibleItems.first!
    }
    
    func photoBrowserDismissFromRect() -> CGRect {
        let cell = collectionView.visibleCells.first as! PhotoPreviewCell
        return UIApplication.shared.delegate!.window!!.convert(cell.imageView.frame, from: cell.scrollView)
    }
    
}



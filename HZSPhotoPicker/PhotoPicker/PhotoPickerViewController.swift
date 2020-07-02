//
//  PhotoPickerViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/19.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos.PHAsset

class PhotoPickerViewController: PhotoPickerBaseViewController {

    // MARK: - Properties[public]
    var albumModel: AlbumModel?
    var shouldScrollToBottom: Bool = true
    
    private var assetModels: [AssetModel] = []
    private var isFromPreview: Bool = false
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    deinit {
        print("PhotoPickerViewController deinit")
    }
    
    private func setupUI() {
        let moreAlbum = UIButton(type: .system)
        moreAlbum.setTitle("更多项目", for: .normal)
        moreAlbum.addTarget(self, action: #selector(handleMoreAlbumAction), for: .touchUpInside)
        navigationItem.titleView = moreAlbum
        
        
        // right bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(handleDismissAction))
        
        let margin: CGFloat = imagePicker.margin
        let columnCount = (navigationController as! ImagePickerController).columnCount
        let width: CGFloat = (view.bounds.width - CGFloat(columnCount - 1) * margin) / CGFloat(columnCount)
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        
        // collectionView
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        // proxy
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.identifier)
        
        if imagePicker.type == .selections {
            // bottomBar
            let height = UIDevice.bottomSafeArea
            bottomBar.frame = CGRect(x: 0, y: view.bounds.height - height, width: view.bounds.width, height: height)
            view.addSubview(bottomBar)
            
            let topPadding: CGFloat = 15
            
            // previewBtn
            previewBtn.frame = CGRect(x: 0, y: topPadding, width: 60, height: 30)
            bottomBar.addSubview(previewBtn)
            
            // originalBtn
            originalBtn.frame = CGRect(x: (bottomBar.bounds.width - 60)/2, y: topPadding, width: 60, height: 30)
            bottomBar.addSubview(originalBtn)

            // senderBtn
            senderBtn.frame = CGRect(x: bottomBar.bounds.width - 60 - 8, y: topPadding, width: 60, height: 30)
            bottomBar.addSubview(senderBtn)
        }
    }
    
    private func loadData() {
        switch ImagePickerManager.shared.autorizationStatus() {
        case .denied:
            let tipText: String
            if let appInfo = Bundle.main.infoDictionary, let appName = appInfo["CFBundleDisplayName"] as? String {
                tipText = "请在手机的[设置-隐私-照片]选项中,允许\(appName)访问你的相册"
            } else {
                tipText = "请在手机的[设置-隐私-照片]选项中,允许访问你的相册"
            }
            let alertView = UIAlertController(title: "无访问权限", message: tipText, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertView.addAction(cancel)
            let setting = UIAlertAction(title: "去设置", style: .default) { (_) in
                if #available(iOS 10, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
            alertView.addAction(setting)
            present(alertView, animated: true, completion: nil)
        case .authorized:
            fetchAssetModels()
        default:
            ImagePickerManager.shared.requestAuthorization { status in
                if status == .authorized {
                    self.fetchAssetModels()
                }
            }
        }

    }
    
    private func fetchAssetModels() {
        
        // 有数据的话直接显示
        if albumModel != nil {
            ImagePickerManager.shared.loadAssets(from: albumModel!.fetchResult) { (assets) in
                self.assetModels = assets
                self.updateCollectionView()
            }
        } else { // 没有传递数据过来，自己加载相机相册
            let allowPickingVideo = (self.imagePicker.type == .avatar) ? false : self.imagePicker.allowPickingVideo
            ImagePickerManager.shared.loadCameraRollAlbumAssets(allowPickingVideo: allowPickingVideo, completion: { (assets) in
                self.assetModels = assets
                self.updateCollectionView()
            })
        }
    }
    
    /// CollectionView reloadData
    private func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.shouldScrollToBottom {
                let indexPath = IndexPath(item: self.collectionView.numberOfItems(inSection: 0) - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Selector
    
    /// 取消点击
    @objc
    private func handleDismissAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// 预览点击
    @objc
    private func handlePreviewAction(_ sender: UIButton) {
        let vc = PhotoPreviewViewController()
        vc.assetModels = Array(imagePicker.selectedModels.values)
        vc.isFromPreview = true
        
        vc.transitioningDelegate = modalTransitionDelegate
        vc.modalPresentationStyle = .custom
        modalTransitionDelegate.presentDelegate = self
        modalTransitionDelegate.dismissDelegate = vc
        
        present(vc, animated: true, completion: nil)
    }
    
    /// 点击更多相册
    @objc
    private func handleMoreAlbumAction() {
        let albumVC = AlbumPickerViewController()
        albumVC.selectAlbum = { album in
            self.albumModel = album
            self.fetchAssetModels()
        }
        addChild(albumVC)
        view.addSubview(albumVC.view)
        albumVC.didMove(toParent: self)
        
        albumVC.view.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -albumVC.view.frame.height)
        UIView.animate(withDuration: 0.35) {
            albumVC.view.transform = .identity
        }
    }
    
    // 原图选项
    @objc
    private func handleOriginalAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc
    private func handleSendAction(_ sender: UIButton) {
        let isOriginal = originalBtn.isSelected
        var selectImages: [UIImage] = []
        
        for (_, model) in self.imagePicker.selectedModels {
            self.group.enter()
            // 线程同步
            _ = self.semaphore.wait(wallTimeout: DispatchWallTime.distantFuture)
            ImagePickerManager.shared.loadPhoto(with: model.asset, isOriginal: isOriginal, completion: { (image, _, isDegraded) in
                if !isDegraded, let image = image {
                    selectImages.append(image)
                    self.semaphore.signal()
                    self.group.leave()
                }
            })
        }
        
        // 照片获取完成后
        group.notify(queue: DispatchQueue.main) {
            // 回调代理方法
            self.imagePicker.pickerDelegate?.imagePickerController?(self.imagePicker, didFinishPickingPhotos: selectImages, isOriginal: isOriginal)
            // 退出
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Properties[private-lazy]
    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        return view
    }()
    
    private lazy var previewBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(handlePreviewAction(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.setTitle("预览", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .disabled)
        btn.isEnabled = false
        return btn
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
    
    private lazy var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    
    private lazy var group: DispatchGroup = DispatchGroup()
    private lazy var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private var imagePicker: ImagePickerController {
        return navigationController as! ImagePickerController
    }
    
    private var modalTransitionDelegate = PhotoBrowserTransitionAnimator()
}

// MARK: - UICollectionViewDataSource

extension PhotoPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCell.identifier, for: indexPath) as! AssetCell
        cell.indexPath = indexPath
        cell.setAssetModel(assetModels[indexPath.row])
        if imagePicker.type == .avatar {
            cell.selectBtn.isHidden = true
        } else {
            cell.selectBlockHander = {[weak self] selectCount in
                let isEnabled = (selectCount > 0)
                self?.previewBtn.isEnabled = isEnabled
                self?.senderBtn.isEnabled = isEnabled
                self?.senderBtn.alpha = (isEnabled ? 1.0 : 0.5)
            }
        }
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension PhotoPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isFromPreview = true
        
        switch (navigationController as! ImagePickerController).type {
        case .avatar:
            let vc = CropViewController()
            vc.assetModel = assetModels[indexPath.item]
            navigationController?.pushViewController(vc, animated: true)
        case .selections:
            let vc = PhotoPreviewViewController()
            vc.assetModels = assetModels
            vc.targetIndexPath = indexPath
            vc.isFromPreview = false

            vc.transitioningDelegate = modalTransitionDelegate
            vc.modalPresentationStyle = .custom
            modalTransitionDelegate.presentDelegate = self
            modalTransitionDelegate.dismissDelegate = vc
            modalTransitionDelegate.indexPath = indexPath
            
            present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - PhotoBrowserPresentDelegate

extension PhotoPickerViewController: PhotoBrowserPresentDelegate {
    
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView {
        let cell = collectionView.cellForItem(at: indexPath) as! AssetCell
        let imageView = UIImageView(image: cell.imageView.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect {
        let cell = collectionView.cellForItem(at: indexPath)!
        if collectionView.indexPathsForVisibleItems.contains(indexPath) {
            return UIApplication.shared.delegate!.window!!.convert(cell.frame, from: collectionView)
        } else {
            return CGRect(origin: CGPoint(x: CGFloat.nan, y: CGFloat.nan), size: cell.frame.size)
        }
    }
    
    func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect {
        let cell = collectionView.cellForItem(at: indexPath) as! AssetCell
        let imageSize = cell.imageView.image?.size ?? .zero
        if imageSize == .zero { return .zero }
        let newHeight = view.bounds.width * imageSize.height / imageSize.width
        return CGRect(x: 0, y: (view.bounds.height - newHeight) / 2, width: view.bounds.width, height: newHeight)
    }
    
}

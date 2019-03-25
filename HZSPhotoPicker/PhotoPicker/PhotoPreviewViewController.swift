//
//  PhotoPreviewViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/4/1.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos.PHAsset

private let kPhotoPreviewCellIdentifier: String = "PhotoPreviewCellIdentifier"

class PhotoPreviewViewController: UIViewController {

    var assetModels: [AssetModel] = []
    var targetIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    private var isStatusHiden: Bool = false
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        addGestureRecognizer()
    }
    
    private func setupSubviews() {
        //rightBarButton-------------------------------
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarBtn)
        
        // collectionView-------------------------------
        let margin: CGFloat = 8
        var rect = view.bounds
        rect.size.width += margin
        
        collectionView = UICollectionView(frame: rect, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.black
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
        collectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: kPhotoPreviewCellIdentifier)
        
        // flowLayout
        flowLayout.itemSize = collectionView.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        // bottomBar-------------------------------
        bottomBar.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
        view.addSubview(bottomBar)
        
        // editBtn
        editBtn.frame = CGRect(x: 0, y: (bottomBar.bounds.height - 30)/2, width: 60, height: 30)
        bottomBar.addSubview(editBtn)
        
        // originalBtn
        originalBtn.frame = CGRect(x: (bottomBar.bounds.width - 60)/2, y: (bottomBar.bounds.height - 30)/2, width: 60, height: 30)
        bottomBar.addSubview(originalBtn)
        
        // senderBtn
        senderBtn.frame = CGRect(x: bottomBar.bounds.width - 60 - 8, y: (bottomBar.bounds.height - 30)/2, width: 60, height: 30)
        bottomBar.addSubview(senderBtn)
    }
    
    private func addGestureRecognizer() {
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapGesture(_:)))
        view.addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        oneTap.require(toFail: doubleTap)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 滑动到指定的indexPath
        collectionView.scrollToItem(at: targetIndexPath, at: .left, animated: false)
        senderBtn.isEnabled = (imagePicker.selectedModels.count > 0)
        senderBtn.alpha = (senderBtn.isEnabled ? 1.0 : 0.5)
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
    
    /// 单击的时候显示或者隐藏bar
    @objc private func oneTapGesture(_ gesture: UITapGestureRecognizer) {
        isStatusHiden.toggle()
        
        // 显示或者隐藏navigationBar
        if #available(iOS 9.0, *) {
//            perform(#selector(setNeedsStatusBarAppearanceUpdate))
            setNeedsStatusBarAppearanceUpdate()
        } else {
            UIApplication.shared.isStatusBarHidden = isStatusHiden
        }
        // 显示或者隐藏statusBar
        imagePicker.setNavigationBarHidden(isStatusHiden, animated: true)
        
        // 显示或者隐藏bottomBar
        UIView.animate(withDuration: 0.25) {
            self.bottomBar.frame.origin.y += (self.isStatusHiden ? 44 : -44)
        }
    }
    
    /// 双击放大图片
    @objc private func doubleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let cell = collectionView.visibleCells.first as? PhotoPreviewCell else { return }
        let point = gesture.location(in: view)
        cell.scrollViewZoom(in: point)
    }

    
    /// 预览点击
    @objc private func editBtnClick(_ sender: UIButton) {
        print("编辑按钮点击")
    }
    
    /// 原图选项
    @objc private func originalBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    /// 发送按钮点击
    @objc private func senderBtnClick(_ sender: UIButton) {
        let isOriginal = originalBtn.isSelected
        
        var selectImages: [UIImage] = []
        var selectAssets: [PHAsset] = []
        
        DispatchQueue.global(qos: .default).async {
            
            for model in self.imagePicker.selectedModels {
                selectAssets.append(model.asset)
                
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
    }
    
    /// 选中按钮
    @objc private func rightBarBtnClick(_ sender: UIButton) {
        let isSelected = sender.isSelected
        
        // 图片不能超过9张提示
        if !isSelected, imagePicker.selectedModels.count >= 9 {
            let alertVC = UIAlertController(title: "图片选择", message: "不能超过9张图片", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "确认", style: .cancel, handler: nil)
            alertVC.addAction(cancel)
            imagePicker.present(alertVC, animated: true, completion: nil)
            return
        }
        
        // 切换状态
        sender.isSelected = !isSelected
        let assetModel = assetModels[currentIndexPath.row]
        assetModel.isSelected = sender.isSelected
        
        if sender.isSelected {
            imagePicker.selectedModels.append(assetModel)
        } else {
            
            let index = imagePicker.selectedModels.firstIndex { (model) -> Bool in
                model.asset == assetModel.asset
            }
            imagePicker.selectedModels.remove(at: index!)
        }
    }
    
    // MARK: - Properties[private-lazy]
    
    private lazy var rightBarBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        btn.setImage(UIImage(named: "photo_choose_def"), for: .normal)
        btn.setImage(UIImage(named: "photo_choose_sel"), for: .selected)
        btn.addTarget(self, action: #selector(rightBarBtnClick(_:)), for: .touchUpInside)
        return btn
    }()

    
    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        return view
    }()
    
    private lazy var editBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(editBtnClick(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.titleLabel?.textColor = UIColor.white
        btn.setTitle("编辑", for: .normal)
        btn.isEnabled = false
        return btn
    }()
    
    private lazy var originalBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(originalBtnClick(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("原图", for: .normal)
        btn.setImage(UIImage(named: "photo_original_def"), for: .normal)
        btn.setImage(UIImage(named: "photo_original_sel"), for: .selected)
        btn.setTitleColor(UIColor.white, for: .normal)
        return btn
    }()
    
    private lazy var senderBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(senderBtnClick(_:)), for: .touchUpInside)
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
        return navigationController as! ImagePickerController
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoPreviewViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoPreviewCellIdentifier, for: indexPath) as! PhotoPreviewCell
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
        rightBarBtn.isSelected = assetModels[indexPath.row].isSelected
        
        // 当前显示cell的indexPath
        currentIndexPath = indexPath
    }
}





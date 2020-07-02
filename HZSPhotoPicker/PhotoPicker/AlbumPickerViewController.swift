//
//  AlbumPickerViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

private let kAlbumCellIdentifier: String = "AlbumCellIdentifier"

class AlbumPickerViewController: PhotoPickerBaseViewController {

    // MARK: - Properties
    
    var selectAlbum: ((AlbumModel) -> Void)?
    
    private var albumModels: [AlbumModel] = []
    private var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Methods-[public]
    
    func fetchAlbums() {
        DispatchQueue.global(qos: .userInitiated).async {
            ImagePickerManager.shared.loadAllAlbums(allowPickingVideo: false, needFetchAssets: true, completion: { (albums) in
                self.albumModels = albums
               
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: - View Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSubviews()
    }
    
    deinit {
        print("AlbumPickerViewController deinit")
    }
    
    private func setupSubviews() {
        view.backgroundColor = UIColor(white: 0.6, alpha: 0.5)
        
        var frame = view.bounds
        frame.size.height *= 3 / 4
        tableView.frame = frame
        view.addSubview(tableView)
        
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AlbumCell.self, forCellReuseIdentifier: kAlbumCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAlbums()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



// MARK: - UITableViewDataSource

extension AlbumPickerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kAlbumCellIdentifier, for: indexPath) as! AlbumCell
        cell.albumModel = albumModels[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AlbumPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消选中效果
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.willMove(toParent: nil)
        UIView.animate(withDuration: 0.35) {
            self.view.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.view.frame.height)
        } completion: { (_) in
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            self.selectAlbum?(self.albumModels[indexPath.row])
        }
    }
}


//
//  ViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    var manager: CLLocationManager!
    
    lazy var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.yellow
        

        let button = UIButton(type: .system)
        button.setTitle(" 相册 ", for: .normal)
        button.addTarget(self, action: #selector(handleClick), for: .touchUpInside)
        button.sizeToFit()
        button.center = view.center
        view.addSubview(button)
        
    }
    
    @objc
    private func handleClick() {
//        let pickerController = ImagePickerController(cropBox: CGSize(width: 300, height: 200), columnCount: 4, delegate: self)
        let pickerController = ImagePickerController(maxSelectableImagesCount: 1, delegate: self)
        pickerController.modalPresentationStyle = .fullScreen
        present(pickerController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: ImagePickerControllerDelegate {
    func imagePickerController(_ picker: ImagePickerController, didFinishPickingPhotos photos: Array<UIImage>, isOriginal: Bool) {
        imageView.image = photos.first
        imageView.sizeToFit()
        imageView.center = view.center
    }
}

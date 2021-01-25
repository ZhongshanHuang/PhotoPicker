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
        
        imageView.backgroundColor = .green
        view.addSubview(imageView)

        let button1 = UIButton(type: .system)
        button1.setTitle("相册-裁剪", for: .normal)
        button1.addTarget(self, action: #selector(handleClick1), for: .touchUpInside)
        button1.sizeToFit()
        button1.center = CGPoint(x: view.center.x, y: view.center.y - 30)
        view.addSubview(button1)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("相册-选择", for: .normal)
        button2.addTarget(self, action: #selector(handleClick2), for: .touchUpInside)
        button2.sizeToFit()
        button2.center = CGPoint(x: view.center.x, y: view.center.y + 30)
        view.addSubview(button2)
    }
    
    @objc
    private func handleClick1() {
        let pickerController = ImagePickerController(cropBox: .ratio(1), columnCount: 4, delegate: self)
        pickerController.modalPresentationStyle = .fullScreen
        present(pickerController, animated: true, completion: nil)
    }
    
    @objc
    private func handleClick2() {
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

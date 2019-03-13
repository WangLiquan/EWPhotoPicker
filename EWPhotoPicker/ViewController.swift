//
//  ViewController.swift
//  EWPhotoPicker
//
//  Created by Ethan.Wang on 2018/9/29.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView =  UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width - EWPickerManager.pickerPhotoSize.width) / 2, y: 100, width: EWPickerManager.pickerPhotoSize.width, height: EWPickerManager.pickerPhotoSize.width))
        imageView.backgroundColor = UIColor.gray
        return imageView
    }()

    private let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 150, y: 450, width:  UIScreen.main.bounds.width - 300, height: 50))
        button.setTitle("相册", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(onClickPhotoButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imageView)
        self.view.addSubview(button)
    }

    @objc private func onClickPhotoButton() {
        let nnvc = EWPhotoPickerViewController(photoDelegate: self)
        /// 可以传入navigationBar.tintColor以保证与项目相同展示效果.默认不传为UIColor.black
//        let PPVC = EWPhotoPickerViewController(photoDelegate: self, tintColor: UIColor.gray)
        self.present(nnvc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: EWImageCropperDelegate {
    func imageCropper(_ cropperViewController: EWPhotoCropViewController, didFinished editImg: UIImage) {
        cropperViewController.navigationController?.dismiss(animated: true, completion: nil)
        self.imageView.image = editImg
    }
}

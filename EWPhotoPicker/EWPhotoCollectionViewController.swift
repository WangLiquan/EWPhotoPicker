//
//  EWPhotoCollectionViewController.swift
//  EWPhotoPicker
//
//  Created by Ethan.Wang on 2018/9/29.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

class EWPhotoCollectionViewController: UIViewController {

    private let navigationBar: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenInfo.Width, height: 88))
        let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 88))
        leftButton.setTitle("返回", for: .normal)
        leftButton.setTitleColor(UIColor.black, for: .normal)
        leftButton.addTarget(self, action: #selector(onClickBackButton), for: .touchUpInside)
        view.addSubview(leftButton)
        return view
    }()

    public var delegate: EWImageCropperDelegate?

    private let manager =  EWPickerManager()
    private var photoArray = [UIImage]()

    private let collectionView: UICollectionView = {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = UICollectionViewScrollDirection.vertical//设置垂直显示
        defaultLayout.minimumLineSpacing = 3 //每个相邻的layout的上下间隔
        defaultLayout.minimumInteritemSpacing = 3.0 //每个相邻layout的左右间隔
        let collectionView = UICollectionView(frame:CGRect(x: 0, y: 88, width: ScreenInfo.Width, height: ScreenInfo.Height - ScreenInfo.navigationHeight), collectionViewLayout: defaultLayout)
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        getPhotoData()
        drawMyView()
    }
    private func drawMyView(){
        self.navigationBar.isHidden = true
        self.view.addSubview(navigationBar)
        self.view.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        for i in 0 ..< photoArray.count+1{
            collectionView.register(EWPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "EWPhotoCollectionViewCell\(i)")
        }
        self.view.addSubview(collectionView)
    }

    @objc private func onClickBackButton(){
        self.dismiss(animated: true, completion: nil)
    }
    func getPhotoData(){
        self.photoArray = manager.getAllPhoto()

    }

    private func cameraShow(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        } else {
            print("模拟器中无法打开照相机,请在真机中使用")
        }
    }

    
}

//MARK: - CollectionViewDelegate
extension EWPhotoCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /// 返回数据数组.count 加一个新建按钮
        return self.photoArray.count + 1
    }
    /// cell点击方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != 0 else {
            cameraShow()
            return
        }
        manager.getPhotoData(index: indexPath.row - 1) { (data, infoDic) in
            guard data != nil else { return }
            let image = UIImage(data: data!)
            let VC = EWPhotoCropViewController(image: image!)
            VC.delegate = self.delegate
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "EWPhotoCollectionViewCell\(indexPath.row)", for: indexPath) as? EWPhotoCollectionViewCell else {
            return EWPhotoCollectionViewCell()
        }
        guard indexPath.row > 0 else { return cell }
        cell.setData(image: photoArray[indexPath.row - 1])
        cell.backgroundColor = UIColor.brown
        return cell
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return EWPickerManager.pickerPhotoSize
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension EWPhotoCollectionViewController:UIImagePickerControllerDelegate& UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: { () -> Void in
        })
        //相册中还可能是视频,所以这里需要判断选择的是不是图片
        let type: String = (info[UIImagePickerControllerMediaType] as! String)
        //当选择的类型是图片
        if type == "public.image" {
            let image:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            //先把图片转成NSData
            let data = UIImageJPEGRepresentation(image, 0.4)
            //图片保存的路径 //这里将图片放在沙盒的documents文件夹中
            let DocumentsPath:String = NSHomeDirectory()+"/Documents"
            //文件管理器
            let fileManager = FileManager.default
            //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
            try! fileManager.createDirectory(atPath: DocumentsPath, withIntermediateDirectories: true, attributes: nil)
            fileManager.createFile(atPath: DocumentsPath + "/image.png", contents: data, attributes: nil)
            //得到选择后沙盒中图片的完整路径
            let filePath = DocumentsPath + "/image.png"
            let previewImage = UIImage(contentsOfFile: filePath)
            let pcvc = EWPhotoCropViewController(image: previewImage!)
            pcvc.delegate = self.delegate
            self.navigationController?.pushViewController(pcvc, animated: true)
        }
    }
}



//
//  EWPhotoCollectionViewController.swift
//  EWPhotoPicker
//
//  Created by Ethan.Wang on 2018/9/29.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

class EWPhotoCollectionViewController: UIViewController {
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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "相册"
        getPhotoData()
        drawMyView()
        drawMyNavigationBar()
    }
    private func drawMyView(){
        self.view.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        /// 使用动态注册阻止collectionView重用
        for i in 0 ..< photoArray.count+1{
            collectionView.register(EWPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "EWPhotoCollectionViewCell\(i)")
        }
        self.view.addSubview(collectionView)
    }
    private func drawMyNavigationBar(){
        let button = UIBarButtonItem(image: EWBundle.imageFromBundle("image_back"), style: .plain, target: self, action: #selector(onClickBackButton))
        self.navigationItem.leftBarButtonItem = button
    }
    /// 获取所有照片
    private func getPhotoData(){
        self.photoArray = manager.getAllPhoto()
    }
    /// 调用相机
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
    @objc private func onClickBackButton(){
        self.dismiss(animated: true, completion: nil)
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
        guard indexPath.row > 0 else {
            cell.setData()
            return cell
        }
        cell.setData(image: photoArray[indexPath.row - 1])
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



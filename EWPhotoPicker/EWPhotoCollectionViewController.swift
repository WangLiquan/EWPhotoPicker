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
        for i in 0 ..< photoArray.count{
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


}

//MARK: - CollectionViewDelegate
extension EWPhotoCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /// 返回数据数组.count 加一个新建按钮
        return self.photoArray.count
    }
    /// cell点击方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        manager.getPhotoData(index: indexPath.row) { (data, infoDic) in
            guard data != nil else { return }
            let image = UIImage(data: data!)
            self.navigationController?.pushViewController(EWPhotoCropViewController(image: image!), animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "EWPhotoCollectionViewCell\(indexPath.row)", for: indexPath) as? EWPhotoCollectionViewCell else {
            return EWPhotoCollectionViewCell()
        }
        cell.setData(image: photoArray[indexPath.row])
        cell.backgroundColor = UIColor.brown
        return cell
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return EWPickerManager.pickerPhotoSize
    }
}



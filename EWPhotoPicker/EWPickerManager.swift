//
//  EWPickerManager.swift
//  EWPhotoPicker
//
//  Created by Ethan.Wang on 2018/9/29.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit
import Photos

class EWPickerManager: NSObject {

    private(set) var photoAlbum  = PHFetchResult<PHAsset>()

    private var photoManage = PHCachingImageManager()
    private let photoOption = PHImageRequestOptions()

    //pickerCell照片的size
    class public var pickerPhotoSize: CGSize {
        let sreenBounds = ScreenInfo.Frame
        let screenWidth = sreenBounds.width > sreenBounds.height ? sreenBounds.height : sreenBounds.width
        let width = (screenWidth - CGFloat(9)) / CGFloat(4)
        return CGSize(width: width, height: width)
    }

    override init() {
        super.init()
        self.photoOption.resizeMode   = .fast
        self.photoOption.deliveryMode = .opportunistic
        self.photoOption.isSynchronous = true
        getPhotoAlbums()
    }

    public func getAllPhoto() -> [UIImage]{
        var imageArray = [UIImage]()
        let scale = UIScreen.main.scale
        /// 重要,不对size进行重置会使显示效果变差
        let photoScaleSize = CGSize(width: EWPickerManager.pickerPhotoSize.width * scale, height: EWPickerManager.pickerPhotoSize.height * scale)
        for i in 0 ..< self.photoAlbum.count {
            self.photoManage.requestImage(for: self.photoAlbum[i], targetSize: photoScaleSize, contentMode: .aspectFill, options: self.photoOption) { (image, infoDic) in
                if image != nil{
                    imageArray.append(image!)
                }
            }
        }
        return imageArray
    }

    public func getPhotoData(index: Int, resultHandler: ((Data?, UIImageOrientation) -> Void)?) {
        self.photoManage.requestImageData(for: self.photoAlbum[index], options: nil, resultHandler: { (data, str, orientation, hashable) in
            resultHandler?(data, orientation)
        })
    }

    private func getPhotoAlbums(){
        //创建一个PHFetchOptions对象检索照片
        let options = PHFetchOptions()
        //通过创建时间来检索
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        //通过数据类型来检索，这里为只检索照片
        options.predicate = NSPredicate.init(format: "mediaType in %@", [PHAssetMediaType.image.rawValue])
        //通过检索条件检索出符合检索条件的所有数据，也就是所有的照片
        let allResult = PHAsset.fetchAssets(with: options)
        //将获取的相册加入到相册的数组中
        photoAlbum = allResult

    }
}

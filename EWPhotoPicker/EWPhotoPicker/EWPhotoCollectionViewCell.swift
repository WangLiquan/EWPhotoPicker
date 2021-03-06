//
//  EWPhotoCollectionViewCell.swift
//  EWPhotoPicker
//
//  Created by Ethan.Wang on 2018/9/29.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

public class EWPhotoCollectionViewCell: UICollectionViewCell {
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds  = true
        imageView.backgroundColor = UIColor.black
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawMyView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func drawMyView() {
        self.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    public func setData(image: UIImage = EWBundle.imageFromBundle("image_camera")!) {
       self.imageView.image = image
    }
}

//
//  CommonHelper.swift
//  EWDatePicker
//
//  Created by Ethan.Wang on 2018/8/27.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import Foundation
import UIKit

struct ScreenInfo {
    static let Frame = UIScreen.main.bounds
    static let Height = Frame.height
    static let Width = Frame.width
    static let navigationHeight:CGFloat = navBarHeight()

    static func isIphoneX() -> Bool {
        return UIScreen.main.bounds.equalTo(CGRect(x: 0, y: 0, width: 375, height: 812))
    }
    static private func navBarHeight() -> CGFloat {
        return isIphoneX() ? 88 : 64
    }
}
/// 获取图片
public struct EWBundle {
    /// 根据budle获取image
    static public func imageFromBundle(_ imageName: String) -> UIImage? {
        var bundle = Bundle(for: EWPickerManager.self)
        if let resourcePath = bundle.path(forResource: "EWPhotoPicker", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }
        if let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) {
            return image
        }
        return nil
    }
}

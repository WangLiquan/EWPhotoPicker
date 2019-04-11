//
//  EWPhotoCropViewController.swift
//  EWPhotoPicker
//
//  Created by Ethan.Wang on 2018/9/30.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit
/// 裁切后的照片返回协议
@objc public protocol EWImageCropperDelegate : NSObjectProtocol {
    func imageCropper(_ cropperViewController:EWPhotoCropViewController, didFinished editImg:UIImage)
}
/// 选中图片后裁切控制器
public class EWPhotoCropViewController: UIViewController {
    /// 初始frame
    private var oldFrame: CGRect?
    /// 最大frame
    private var largeFrame: CGRect?
    /// 裁切区域frame
    private var cropFrame: CGRect?
    /// 最后结果frame
    private var latestFrame: CGRect?
    /// 选中的照片
    private var selectedPhoto: UIImage = UIImage()

    public weak var delegate: EWImageCropperDelegate?
    /// 遮挡在选中imageView上层的半透明View
    private let overlayView: UIView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenInfo.Width, height: ScreenInfo.Height))
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.isUserInteractionEnabled = false
        return view
    }()
    /// 裁切区域View
    private let cropView: UIView = {
        let view = UIView(frame: CGRect(x: 0 , y: (ScreenInfo.Height - ScreenInfo.Width) / 2, width: ScreenInfo.Width, height: ScreenInfo.Width))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.yellow.cgColor
        return view
    }()
    /// 展示图片背景View
    private let backImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenInfo.Width, height: ScreenInfo.Height))
        imageView.isMultipleTouchEnabled = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience init(image: UIImage) {
        self.init(nibName: nil, bundle: nil)
        /// 保证图片方向
        self.selectedPhoto = self.fixOrientation(image)
        self.backImageView.image = selectedPhoto
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        drawMyView()
        drawMyNavigationBar()
    }
    private func drawMyView() {
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(backImageView)
        initViewsFrame()
        self.view.addSubview(overlayView)
        self.view.addSubview(cropView)
        overlayClipping()
        drawBottomButtonView()
        addGestureRecognizers()
    }
    private func drawMyNavigationBar() {
        let button = UIBarButtonItem(image: EWBundle.imageFromBundle("image_back"), style: .plain, target: self, action: #selector(onClickCancelbuton))
        self.navigationItem.leftBarButtonItem = button
    }
    private func initViewsFrame() {
        /// 裁切区域Width
        let cropWidth = UIScreen.main.bounds.width
        /// 获取选中图片width等于裁切区域时的height
        let photoOldHeight = selectedPhoto.size.height / selectedPhoto.size.width * cropWidth
        // 判断选中图片OldHeight
        if photoOldHeight > ScreenInfo.Height {
            // 大于屏幕尺寸,则正常展示
            self.backImageView.frame = CGRect(x: 0, y: 0, width: cropWidth, height: photoOldHeight)
        } else {
            // 小于屏幕尺寸,将其置于中心展示
            self.backImageView.frame = CGRect(x: 0, y: (ScreenInfo.Height - photoOldHeight) / 2 , width: cropWidth, height: photoOldHeight)
        }
        /// 获取照片展示oldFrame
        oldFrame = self.backImageView.frame
        /// 初始化lastestFrame,使其为oldFrame
        latestFrame = self.oldFrame
        /// 初始化最大frame.使其为oldFrame.size*3 也就是设定图片放大比例不能超过3倍
        largeFrame = CGRect(x: 0, y: 0, width: (oldFrame?.size.width)! * 3, height: (oldFrame?.size.height)! * 3)
        /// 裁切frame就是裁切View.frame
        cropFrame = self.cropView.frame
    }
    /// 添加下方取消与完成按钮
    private func drawBottomButtonView() {
        let centerView = UIView(frame:CGRect(x: 100, y: self.view.frame.size.height - 50.0, width: self.view.frame.size.width-200, height: 50))
        centerView.backgroundColor = UIColor.black
        centerView.alpha = 0.5
        self.view.addSubview(centerView)
        let cancelBtn = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 50.0, width: 100, height: 50))
        cancelBtn.backgroundColor = UIColor.black
        cancelBtn.alpha = 0.5
        cancelBtn.titleLabel?.textColor = UIColor.white
        cancelBtn.setTitle("取消", for: UIControl.State())
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        cancelBtn.titleLabel?.textAlignment = NSTextAlignment.center
        cancelBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cancelBtn.titleLabel?.numberOfLines = 0
        cancelBtn.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        cancelBtn.addTarget(self, action:#selector(onClickCancelbuton), for: UIControl.Event.touchUpInside)
        self.view.addSubview(cancelBtn)
        let confirmBtn:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100.0, y: self.view.frame.size.height - 50.0, width: 100, height: 50))
        confirmBtn.backgroundColor = UIColor.black
        confirmBtn.alpha = 0.5
        confirmBtn.titleLabel?.textColor = UIColor.white
        confirmBtn.setTitle("确定", for: UIControl.State())
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        confirmBtn.titleLabel?.textAlignment = NSTextAlignment.center
        confirmBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        confirmBtn.titleLabel?.numberOfLines = 0
        confirmBtn.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        confirmBtn.addTarget(self, action:#selector(onClickConfirmButton), for: UIControl.Event.touchUpInside)
        self.view.addSubview(confirmBtn)
    }
    /// 修改overlayView.layer.使cropView不被遮挡
    private func overlayClipping() {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        // 裁切View左侧side
        path.addRect(CGRect(x: 0, y: 0, width: self.cropView.frame.origin.x, height: self.overlayView.frame.size.height))
        // 裁切View右侧side
        path.addRect(CGRect(
            x: self.cropView.frame.origin.x + self.cropView.frame.size.width, y: 0, width: self.overlayView.frame.size.width - self.cropView.frame.origin.x - self.cropView.frame.size.width, height: self.overlayView.frame.size.height))
        // 裁切View上方side
        path.addRect(CGRect(x: 0, y: 0, width: self.overlayView.frame.size.width, height: self.cropView.frame.origin.y))
        // 裁切View下方side
        path.addRect(CGRect(x: 0, y: self.cropView.frame.origin.y + self.cropView.frame.size.height, width: self.overlayView.frame.size.width, height: self.overlayView.frame.size.height - self.cropView.frame.origin.y + self.cropView.frame.size.height))
        maskLayer.path = path
        /// 修改overlayView.将裁切View区域空白出来
        self.overlayView.layer.mask = maskLayer
        path.closeSubpath()
    }
    /// 添加缩放,以及拖拽手势
    private func addGestureRecognizers() {
        // 缩放手势
        let pinchGestureRecognizer:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(_:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
        // 拖拽手势
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panView(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    /// 缩放手势方法
    @objc private func pinchView(_ pinchGestureRecognizer:UIPinchGestureRecognizer) {
        if pinchGestureRecognizer.state == .began || pinchGestureRecognizer.state == .changed {
            /// 当缩放手势开始,以及正在进行中时,根据手势缩放比例对应将展示照片的backImageView通过transform进行等比例缩放
            self.backImageView.transform = backImageView.transform.scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
            pinchGestureRecognizer.scale = 1
        } else if pinchGestureRecognizer.state == .ended {
            /// 获取手势结束后backImageView.frame,并通过验证方法对其修正
            var newFrame = self.backImageView.frame
            /// 修正比例
            newFrame = handleScaleOverflow(newFrame)
            /// 修正位置
            newFrame = handleBorderOverflow(newFrame)
            /// 使backImageView.frame变为修正后的frame,并添加动画效果
            UIView.animate(withDuration: 0.3) {
                self.backImageView.frame = newFrame
                self.latestFrame = newFrame
            }
        }
    }
    //拖拽手势方法
    @objc private func panView(_ panGestureRecognizer:UIPanGestureRecognizer) {
        let view = self.backImageView
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            /// 当拖拽手势开始以及正在进行中时,根据拖拽位移以及图片比例,通过修改view.center实现拖拽效果
            let absCenterX = self.cropFrame!.origin.x + self.cropFrame!.size.width / 2
            let absCenterY = self.cropFrame!.origin.y + self.cropFrame!.size.height / 2
            let scaleRatio = self.backImageView.frame.size.width / self.cropFrame!.size.width
            let acceleratorX = 1 - abs(absCenterX - view.center.x) / (scaleRatio * absCenterX)
            let acceleratorY = 1 - abs(absCenterY - view.center.y) / (scaleRatio * absCenterY)
            let translation = panGestureRecognizer.translation(in: view.superview)
            view.center = CGPoint(x:view.center.x + translation.x * acceleratorX, y: view.center.y + translation.y * acceleratorY)
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        } else if panGestureRecognizer.state == .ended {
            /// 获取手势结束后backImageView.frame,并通过验证方法对其修正
            var newFrame = self.backImageView.frame
            /// 修正位置
            newFrame = self.handleBorderOverflow(newFrame)
            UIView.animate(withDuration: 0.3) {
                /// 使backImageView.frame变为修正后的frame,并添加动画效果
                self.backImageView.frame = newFrame
                self.latestFrame = newFrame
            }
        }
    }
    /// 点击取消按钮
    @objc private func onClickCancelbuton() {
        self.navigationController?.popViewController(animated: true)
    }
    /// 点击完成按钮
    @objc private func onClickConfirmButton() {
        if delegate != nil {
            if self.delegate!.responds(to: #selector(EWImageCropperDelegate.imageCropper(_:didFinished:))) {
                self.delegate!.imageCropper(self, didFinished: self.getSubImage())
            }
        }
    }
    /// 获取截取图片
    private func getSubImage() -> UIImage {
        /// 获取截取位置Frame
        let squareFrame = self.cropFrame!
        /// 获取图片缩放比例
        let scaleRatio = self.latestFrame!.size.width / self.selectedPhoto.size.width
        var x = (squareFrame.origin.x - self.latestFrame!.origin.x) / scaleRatio
        var y = (squareFrame.origin.y - self.latestFrame!.origin.y) / scaleRatio
        var w = squareFrame.size.width / scaleRatio
        var h = squareFrame.size.height / scaleRatio
        if self.latestFrame!.size.width < self.cropFrame!.size.width {
            let newW = self.selectedPhoto.size.width
            let newH = newW * (self.cropFrame!.size.height / self.cropFrame!.size.width)
            x = 0
            y += (h - newH) / 2
            w = newH
            h = newH
        }
        if self.latestFrame!.size.height < self.cropFrame!.size.height {
            let newH = self.selectedPhoto.size.height
            let newW = newH * (self.cropFrame!.size.width / self.cropFrame!.size.height)
            x += (w - newW) / 2
            y = 0
            w = newH
            h = newH
        }
        /// 获取截取图片的frame
        let myImageRect = CGRect(x: x, y: y, width: w, height: h)
        let imageRef = self.selectedPhoto.cgImage
        let subImageRef = imageRef?.cropping(to: myImageRect)
        let size:CGSize = CGSize(width: myImageRect.size.width, height: myImageRect.size.height)
        UIGraphicsBeginImageContext(size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.draw(subImageRef!, in: myImageRect)
        let smallImage = UIImage(cgImage: subImageRef!)
        UIGraphicsEndImageContext()
        return smallImage
    }
    /// 修正size不小于初始值,不大于最大值
    ///
    /// - Parameter newFrame: 变更过的frame
    /// - Returns: 修正后frame
    private func handleScaleOverflow(_ newFrame:CGRect) -> CGRect {
        var newFrame = newFrame
        let oriCenter = CGPoint(x: newFrame.origin.x + newFrame.size.width / 2, y: newFrame.origin.y + newFrame.size
            .height / 2)
        /// 如果frame.size小于最小值则使其等于最小值
        if newFrame.size.width < self.oldFrame!.size.width {
            newFrame = self.oldFrame!
        }
        /// 如果frame.size大于最大值则使其等于最大值
        if newFrame.size.width > self.largeFrame!.size.width {
            newFrame = self.largeFrame!
        }
        newFrame.origin.x = oriCenter.x - newFrame.size.width / 2
        newFrame.origin.y = oriCenter.y - newFrame.size.height / 2
        return newFrame
    }
    /// 修正frame保证view展示不超过裁切区域
    private func handleBorderOverflow(_ newFrame:CGRect) -> CGRect {
        var newFrame = newFrame
        if newFrame.origin.x > self.cropFrame!.origin.x {
            newFrame.origin.x = self.cropFrame!.origin.x
        }
        if newFrame.maxX < self.cropFrame!.size.width {
            newFrame.origin.x = self.cropFrame!.size.width - newFrame.size.width
        }
        if newFrame.origin.y > self.cropFrame!.origin.y {
            newFrame.origin.y = self.cropFrame!.origin.y
        }
        if newFrame.maxY < self.cropFrame!.origin.y + self.cropFrame!.size.height {
            newFrame.origin.y = self.cropFrame!.origin.y + self.cropFrame!.size.height - newFrame.size.height
        }
        if self.backImageView.frame.size.width > self.backImageView.frame.size.height && newFrame.size.height <= self.cropFrame!.size.height {
            newFrame.origin.y = self.cropFrame!.origin.y + (self.cropFrame!.size.height - newFrame.size.height) / 2
        }
        return newFrame
    }
}
extension EWPhotoCropViewController {
    // 保证图片方向
    private func fixOrientation(_ srcImg:UIImage) -> UIImage {
        if srcImg.imageOrientation == UIImage.Orientation.up {
            return srcImg
        }
        var transform = CGAffineTransform.identity
        switch srcImg.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: srcImg.size.width, y: srcImg.size.height)
            transform = transform.rotated(by: .pi)
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: srcImg.size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: srcImg.size.height)
            transform = transform.rotated(by: -.pi/2)
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored: break
        @unknown default:
            break
        }
        switch srcImg.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: srcImg.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: srcImg.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:break
        @unknown default:
            break
        }
        // 上下文
        let ctx:CGContext = CGContext(data: nil, width: Int(srcImg.size.width), height: Int(srcImg.size.height), bitsPerComponent: srcImg.cgImage!.bitsPerComponent, bytesPerRow: 0, space: srcImg.cgImage!.colorSpace!, bitmapInfo: srcImg.cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        switch srcImg.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(srcImg.cgImage!, in: CGRect(x: 0, y: 0, width: srcImg.size.height, height: srcImg.size.width))
        default:
            ctx.draw(srcImg.cgImage!, in: CGRect(x: 0, y: 0, width: srcImg.size.width, height: srcImg.size.height))
        }
        let cgImg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgImg)
        ctx.closePath()
        return img
    }
}

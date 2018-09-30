//
//  EWPhotoCropViewController.swift
//  EWPhotoPicker
//
//  Created by Ethan.Wang on 2018/9/30.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

@objc protocol EWImageCropperDelegate : NSObjectProtocol {
    func imageCropper(_ cropperViewController:EWPhotoCropViewController, didFinished editImg:UIImage)
}
/// 选中图片后裁切控制器
class EWPhotoCropViewController: UIViewController {

    private var oldFrame: CGRect?
    private var largeFrame: CGRect?
    private var cropFrame: CGRect?
    private var latestFrame: CGRect?

    private var selectedPhoto: UIImage = UIImage()

    var delegate: EWImageCropperDelegate?

    private let overlayView: UIView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenInfo.Width, height: ScreenInfo.Height))
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.isUserInteractionEnabled = false
        return view
    }()
    private let cropView: UIView = {
        let view = UIView(frame: CGRect(x: 0 , y: (ScreenInfo.Height - ScreenInfo.Width) / 2, width: ScreenInfo.Width, height: ScreenInfo.Width))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.yellow.cgColor
        return view
    }()
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
        self.selectedPhoto = image
        self.backImageView.image = selectedPhoto
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        drawMyView()
    }
    private func drawMyView(){
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(backImageView)
        initViewsFrame()
        self.view.addSubview(overlayView)
        self.view.addSubview(cropView)
        overlayClipping()
        drawBottomButtonView()
        addGestureRecognizers()
    }
    private func initViewsFrame(){
        let cropWidth = UIScreen.main.bounds.width
        let photoOldHeight = selectedPhoto.size.height / selectedPhoto.size.width * cropWidth
        if photoOldHeight > ScreenInfo.Height {
            self.backImageView.frame = CGRect(x: 0, y: 0, width: cropWidth, height: photoOldHeight)
        }else{
            self.backImageView.frame = CGRect(x: 0, y: (ScreenInfo.Height - photoOldHeight) / 2 , width: cropWidth, height: photoOldHeight)
        }
        oldFrame = self.backImageView.frame
        self.latestFrame = self.oldFrame
        largeFrame = CGRect(x: 0, y: 0, width: (oldFrame?.size.width)! * 3, height: (oldFrame?.size.height)! * 3)
        cropFrame = self.cropView.frame
    }
    private func drawBottomButtonView(){
        let centerView = UIView(frame:CGRect(x: 100, y: self.view.frame.size.height - 50.0, width: self.view.frame.size.width-200, height: 50))
        centerView.backgroundColor = UIColor.black
        centerView.alpha = 0.5
        self.view.addSubview(centerView)
        let cancelBtn = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 50.0, width: 100, height: 50))
        cancelBtn.backgroundColor = UIColor.black
        cancelBtn.alpha = 0.5
        cancelBtn.titleLabel?.textColor = UIColor.white
        cancelBtn.setTitle("取消", for: UIControlState())
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        cancelBtn.titleLabel?.textAlignment = NSTextAlignment.center
        cancelBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cancelBtn.titleLabel?.numberOfLines = 0
        cancelBtn.titleEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
        cancelBtn.addTarget(self, action:#selector(onClickCancelbuton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelBtn)
        let confirmBtn:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100.0, y: self.view.frame.size.height - 50.0, width: 100, height: 50))
        confirmBtn.backgroundColor = UIColor.black
        confirmBtn.alpha = 0.5
        confirmBtn.titleLabel?.textColor = UIColor.white
        confirmBtn.setTitle("确定", for: UIControlState())
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        confirmBtn.titleLabel?.textAlignment = NSTextAlignment.center
        confirmBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        confirmBtn.titleLabel?.numberOfLines = 0
        confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
        confirmBtn.addTarget(self, action:#selector(onClickConfirmButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(confirmBtn)
    }
    /// 修改overlayView.layer.使cropView不被遮挡
    private func overlayClipping() {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        // Left side of the ratio view
        path.addRect(CGRect(x: 0, y: 0, width: self.cropView.frame.origin.x, height: self.overlayView.frame.size.height))
        // Right side of the ratio view
        path.addRect(CGRect(
            x: self.cropView.frame.origin.x + self.cropView.frame.size.width, y: 0, width: self.overlayView.frame.size.width - self.cropView.frame.origin.x - self.cropView.frame.size.width, height: self.overlayView.frame.size.height))
        // Top side of the ratio view
        path.addRect(CGRect(x: 0, y: 0, width: self.overlayView.frame.size.width, height: self.cropView.frame.origin.y))
        // Bottom side of the ratio view
        path.addRect(CGRect(x: 0, y: self.cropView.frame.origin.y + self.cropView.frame.size.height, width: self.overlayView.frame.size.width, height: self.overlayView.frame.size.height - self.cropView.frame.origin.y + self.cropView.frame.size.height))
        maskLayer.path = path
        self.overlayView.layer.mask = maskLayer
        path.closeSubpath()
    }
    private func addGestureRecognizers() {
        // pinch
        let pinchGestureRecognizer:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(_:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)

        // pan
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panView(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    @objc private func pinchView(_ pinchGestureRecognizer:UIPinchGestureRecognizer) {
        if pinchGestureRecognizer.state == .began || pinchGestureRecognizer.state == .changed{
            self.backImageView.transform = backImageView.transform.scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
            pinchGestureRecognizer.scale = 1
        }else if pinchGestureRecognizer.state == .ended{
            var newFrame = self.backImageView.frame
            newFrame = handleScaleOverflow(newFrame)
            newFrame = handleBorderOverflow(newFrame)
            UIView.animate(withDuration: 0.3) {
                self.backImageView.frame = newFrame
                self.latestFrame = newFrame
            }
        }
    }
    //pan gesture handler
    @objc private func panView(_ panGestureRecognizer:UIPanGestureRecognizer) {
        let view = self.backImageView
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed{
            let absCenterX = self.cropFrame!.origin.x + self.cropFrame!.size.width / 2
            let absCenterY = self.cropFrame!.origin.y + self.cropFrame!.size.height / 2
            let scaleRatio = self.backImageView.frame.size.width / self.cropFrame!.size.width
            let acceleratorX = 1 - abs(absCenterX - view.center.x) / (scaleRatio * absCenterX)
            let acceleratorY = 1 - abs(absCenterY - view.center.y) / (scaleRatio * absCenterY)
            let translation = panGestureRecognizer.translation(in: view.superview)
            view.center = CGPoint(x:view.center.x + translation.x * acceleratorX, y: view.center.y + translation.y * acceleratorY)
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        }else if panGestureRecognizer.state == .ended{
            var newFrame = self.backImageView.frame
            newFrame = self.handleBorderOverflow(newFrame)
            UIView.animate(withDuration: 0.3) {
                self.backImageView.frame = newFrame
                self.latestFrame = newFrame
            }
        }
    }



    @objc private func onClickCancelbuton(){
        self.navigationController?.popViewController(animated: true)
    }
    @objc private func onClickConfirmButton(){
        if delegate != nil{
            if self.delegate!.responds(to: #selector(EWImageCropperDelegate.imageCropper(_:didFinished:))) {
                self.delegate!.imageCropper(self, didFinished: self.getSubImage())
            }
        }
    }
    private func getSubImage() -> UIImage {
        let squareFrame = self.cropFrame!
        let scaleRatio = self.latestFrame!.size.width / self.selectedPhoto.size.width
        var x = (squareFrame.origin.x - self.latestFrame!.origin.x) / scaleRatio
        var y = (squareFrame.origin.y - self.latestFrame!.origin.y) / scaleRatio
        var w = squareFrame.size.width / scaleRatio
        var h = squareFrame.size.height / scaleRatio
        if self.latestFrame!.size.width < self.cropFrame!.size.width {
            let newW = self.selectedPhoto.size.width
            let newH = newW * (self.cropFrame!.size.height / self.cropFrame!.size.width)
            x = 0;
            y = y + (h - newH) / 2
            w = newH
            h = newH
        }
        if self.latestFrame!.size.height < self.cropFrame!.size.height {
            let newH = self.selectedPhoto.size.height
            let newW = newH * (self.cropFrame!.size.width / self.cropFrame!.size.height)
            x = x + (w - newW) / 2
            y = 0
            w = newH
            h = newH
        }

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

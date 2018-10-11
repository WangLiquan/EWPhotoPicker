# EWPhotoPicker
<h3>自定制相册,实现相册列表首个cell是相机按钮功能</h3>

# 实现思路:

1.使用photos框架获取手机内所有图片.

2.使用CollectionView将图片展示,并实现首个cell是相机按钮功能.

3.新建控制器实现选中照片编辑功能.

4.使用代理将编辑完照片回调.

<br>

![效果图预览](https://github.com/WangLiquan/EWPhotoPicker/raw/master/images/demonstration.gif)

# 添加方法:
#####1.使用CocoaPods加载.
在podfile文件中添加
```
pod 'EWPhotoPicker'
```
#####2.直接从github下载项目将EWPhotoPicker文件夹拖入项目.
# 调用方法:
1.首先给项目info.plist文件中添加相机与相册权限,权限提示自行修改
```
<key>NSPhotoLibraryUsageDescription</key>
<string>相册权限</string>
<key>NSCameraUsageDescription</key>
<string>相机权限</string>
```
2.调用相册时:
先让弹出相册的控制器遵循EWImageCropperDelegate.并在代理方法中获取image.
当需要弹出相册时直接初始化EWPhotoPickerViewController,调用present方法.
```
/// 弹出控制器时时直接present就可以
@objc private func onClickPhotoButton(){
    let nnvc = EWPhotoPickerViewController(photoDelegate: self)
    /// 可以传入navigationBar.tintColor以保证与项目相同展示效果.默认不传为UIColor.black
    //        let PPVC = EWPhotoPickerViewController(photoDelegate: self, tintColor: UIColor.gray)
    self.present(nnvc, animated: true, completion: nil)
}

/// 调用控制器遵循EWImageCropperDelegate,实现唯一的方法.
extension ViewController: EWImageCropperDelegate{
    func imageCropper(_ cropperViewController: EWPhotoCropViewController, didFinished editImg: UIImage) {
        cropperViewController.navigationController?.dismiss(animated: true, completion: nil)
            ///对选取并编辑后的图片直接使用
        self.imageView.image = editImg
    }
}
```

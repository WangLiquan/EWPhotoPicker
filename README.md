# EWPhotoPicker
<h3>自定制相册,实现相册列表首个cell是相机按钮功能</h3>

# 实现思路:

1.使用photos框架获取手机内所有图片.

2.使用CollectionView将图片展示,并实现首个cell是相机按钮功能.

3.新建控制器实现选中照片编辑功能.

4.使用代理将编辑完照片回调.

<br>

![效果图预览](https://github.com/WangLiquan/EWPhotoPicker/raw/master/images/demonstration.gif)

# 使用方法:
将EWPhotoPicker文件夹拖入项目,调用时:
```
/// 调用控制器遵循EWImageCropperDelegate,实现唯一的方法.
extension ViewController: EWImageCropperDelegate{
    func imageCropper(_ cropperViewController: EWPhotoCropViewController, didFinished editImg: UIImage) {
        cropperViewController.navigationController?.dismiss(animated: true, completion: nil)
        ///对选取并编辑后的图片直接使用
        self.imageView.image = editImg
    }
}
/// 弹出控制器时时直接present就可以
@objc private func onClickPhotoButton(){
    let nnvc = EWPhotoPickerViewController(photoDelegate: self)
    self.present(nnvc, animated: true, completion: nil)
}

```

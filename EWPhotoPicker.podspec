

Pod::Spec.new do |s|
  s.name         = "EWPhotoPicker"
  s.version      = "0.0.2"
  #主要标题
  s.summary      = "a swift photo picker"
  #详细描述（必须大于主要标题的长度）
  s.description  = <<-DESC
       一个自定制的实现首个cell是相机的相册
                   DESC
  #仓库主页
  s.homepage     = "https://github.com/wangliquan/EWPhotoPicker"
  s.license      = "MIT"
  s.author       = { "wangliquan" => "wang197200@163.com" }
  s.platform     = :ios,'8.0'
  #仓库地址（注意下tag号）
  s.source       = { :git => "https://github.com/WangLiquan/EWPhotoPicker.git", :tag => "#{s.version}" }
  s.source_files = "EWPhotoPicker/EWPhotoPicker/*.swift"
  s.framework    = "UIKit","Foundation","Photos"
  s.requires_arc = true

end
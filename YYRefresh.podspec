Pod::Spec.new do |s|

  s.name         = "YYRefresh"
  s.version      = "0.0.1"
  s.summary      = "下拉刷新视图"

  s.description  = <<-DESC
  封装MJrefresh 和 DZNEmptyDataSet
                   DESC

  s.homepage     = "https://github.com/YyItRoad/YYRefresh.git"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "杨洋" => "158954945@qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/YyItRoad/YYRefresh.git", :tag => s.version.to_s }

  s.source_files  = "YYRefresh", "YYRefresh/*.{h,m}"

  s.frameworks  =  "UIKit", "Foundation"

  s.dependency 'MJRefresh', '~> 3.0.0'

  s.dependency 'DZNEmptyDataSet'

end

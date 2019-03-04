Pod::Spec.new do |s|
  s.name             = 'TPDataKit'
  s.version          = '1.0.0'
  s.summary          = 'The purpose of TPDataKit is to provide some common tools'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TPDataKit 是一个数据工具类的库
                       DESC

  s.homepage         = 'https://github.com/Topredator/TPDataKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Topredator' => 'luyanggold@163.com' }
  s.source           = { :git => 'https://github.com/Topredator/TPDataKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.source_files = 'TPDataKit/Classes/TPDataKit.h'
  
  s.subspec 'Base' do |ss|
      ss.source_files = 'TPDataKit/Classes/Base/**/*'
  end
  s.subspec 'UIKit' do |ss|
      ss.source_files = 'TPDataKit/Classes/UIKit/**/*'
      ss.dependency 'TPDataKit/Base'
  end
end

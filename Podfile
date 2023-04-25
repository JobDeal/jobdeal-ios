# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'JobDeal' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'Alamofire', '~> 4.0.0'
  pod 'SnapKit'
  pod 'SDWebImage'
  pod 'SwiftyJSON'
  pod 'TweeTextField'
  pod 'SideMenu'
  pod 'GoogleMaps-m1', git: 'https://github.com/khramtsoff/GoogleMaps-m1'
  pod 'TransitionButton'
  pod 'MXParallaxHeader'
  pod 'ParallaxHeader'
  pod 'Cosmos'
  pod 'Toast-Swift'
  pod 'PWSwitch'
  pod 'AssetsPickerViewController'
  pod 'KMPlaceholderTextView'
  pod 'MultiSlider'
  pod 'KlarnaCheckoutSDK'
  pod 'IHProgressHUD', :git => 'https://github.com/Swiftify-Corp/IHProgressHUD.git'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'SwiftEntryKit'
  pod 'TTRangeSlider'
  pod 'IQKeyboardManager'
  pod 'ImageViewer'
  pod 'MaterialComponents/Buttons'
  pod 'Device'
  pod 'libPhoneNumber-iOS'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end

#Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'DeepSoundiOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for DeepSoundiOS

  
  pod 'XLPagerTabStrip', '~> 8.1.0'
  pod 'IQKeyboardManagerSwift'
  pod 'Alamofire'
  pod 'SwiftyBeaver'
  pod 'JGProgressHUD'
  pod 'Toast-Swift', '~> 4.0.0'
  pod "AsyncSwift"
  pod 'GoogleSignIn', '5.0.0'
  pod 'FBSDKLoginKit'
  pod 'SDWebImage', '~> 4.0'
  pod 'DropDown', '2.3.4'
  pod 'R.swift', '6.0.0'
  pod 'SkyFloatingLabelTextField', '~> 3.0'
  pod 'ReachabilitySwift', '~> 4.3.0'
  pod 'TransitionButton'
  pod 'HMSegmentedControl'
# pod 'Floaty'
  pod 'ActionSheetPicker-3.0', '~> 2.3.0'
  pod 'PVSwitch'
  pod 'CircleProgressView', '~> 1.0'
  pod 'FittedSheets'
  pod 'SwiftEventBus', '~> 5.0'
  pod 'INSPhotoGallery'
  pod 'Braintree'
  pod 'BraintreeDropIn'
  pod 'Google-Mobile-Ads-SDK'
  pod 'MarqueeLabel'
  pod 'YNExpandableCell'
  pod 'ExpyTableView'
#  pod 'ImageSlideshow', '~> 1.9.0'
  pod "ImageSlideshow/SDWebImage"
#  pod "ImageSlideshow/Kingfisher"
pod 'razorpay-pod','1.1.16'
pod 'EmptyDataSet-Swift', '~> 5.0.0'
pod 'PaystackCheckout', '~> 0.1'
pod 'AuthorizeNetAccept'
pod "PureLayout", '3.1.8'

#pod 'Stripe'
pod 'PanModal'
pod 'EzPopup'
pod 'SkeletonView'

  target 'DeepSoundiOSTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'DeepSoundiOSUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end


post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end


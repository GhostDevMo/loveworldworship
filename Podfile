# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DeepSoundiOS' do
  # Comment the next line if you don't want to use dynamic frameworks
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
  pod 'SDWebImage'
  pod 'DropDown', '2.3.4'
  pod 'R.swift'
  pod 'ReachabilitySwift', '~> 4.3.0'
  pod 'SwiftEventBus', '~> 5.0'
  pod 'INSPhotoGallery'
  pod 'Braintree'
  pod 'Google-Mobile-Ads-SDK'
  pod 'ExpyTableView'
  pod "ImageSlideshow/SDWebImage"
  pod 'razorpay-pod'
  pod 'EmptyDataSet-Swift', '~> 5.0.0'
  pod 'PaystackCheckout', '~> 0.1'
  pod 'AuthorizeNetAccept'
  pod 'Stripe'
  pod 'EzPopup'
  pod 'SkeletonView'

  target 'DeepSoundiOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DeepSoundiOSUITests' do
    # Pods for testing
  end

end

target 'OneSignalNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OneSignalNotificationServiceExtension

  pod 'OneSignal', '>= 2.6.2', '< 3.0'

end

deployment_target = '13.0'

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
      end
    end
    project.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
    end
  end
end

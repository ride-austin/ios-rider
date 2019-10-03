platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'

abstract_target 'rider_pods' do
#    pod 'MRCountryPicker', :git => 'https://github.com/tedgonzalez/MRCountryPicker.git' #swift 3
#    pod 'TrueTime' #swift 3
#    pod 'PermissionScope', :git => 'https://github.com/tedgonzalez/PermissionScope.git', :commit => 'daf7f7ff1f6c885ad30e7c185779d72fa9cb7b13' # swift 3

    pod 'MRCountryPicker', :git => 'https://github.com/tedgonzalez/MRCountryPicker.git', :branch => 'fixed-canada-issue' #swift 4
    pod 'TrueTime', :git => 'https://github.com/instacart/TrueTime.swift.git', :tag => '5.0.0'
    pod 'FBSDKCoreKit'
    pod 'FBSDKShareKit'
    pod 'FBSDKLoginKit'
    pod 'Mantle'
    pod 'GoogleAnalytics'
    pod 'GoogleMaps', '~> 3.2.0'
    pod 'GooglePlaces', '~> 3.2.0'
    pod 'Stripe'
    pod 'SVProgressHUD'
    pod 'AFNetworking'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Firebase/Analytics'
    pod 'Firebase/Core'
    pod 'Firebase/InAppMessagingDisplay'
    pod 'Firebase/Messaging'
    pod 'SAMKeychain'
    pod 'SDWebImage'
    pod 'Shimmer'
    pod 'TTTAttributedLabel'
    pod 'ZLPeoplePickerViewController'
    pod 'KVOController'
    pod 'XLForm'
    pod 'OHHTTPStubs'
    pod 'BugfenderSDK/ObjC'
    pod 'Appirater'
    #pod 'STLocationRequest'
    pod 'BFRImageViewer'
    pod 'Branch'
    pod 'RxCocoa'
    pod 'Pulley'
    pod 'URITemplate'
    
    #only on compile time
    pod 'SwiftGen'
    pod 'SwiftLint'
    
    target 'RideAustin'
    target 'RideAustinTest'
    target 'RideAustinTest-Automation' do
        pod 'SWHttpTrafficRecorder'
    end
    target 'RA Fresh Test Automation' do
        pod 'SWHttpTrafficRecorder'
    end

    target 'RideAustinTests' do
        inherit! :complete
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['PermissionScope','MRCountryPicker'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_SWIFT3_OBJC_INFERENCE'] = 'On'
            end
        end
    end
end

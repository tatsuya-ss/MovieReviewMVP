# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'MovieReviewMVP' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'FirebaseUI'
pod 'GoogleAnalytics'
pod 'Firebase/Firestore'
pod 'FirebaseFirestoreSwift', '~> 7.3-beta'
pod 'Google-Mobile-Ads-SDK'

pod 'Cosmos', '~> 23.0' 

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
#        // https://ja.stackoverflow.com/questions/75878/xcode-swift-m1macのデバックモードのみ-no-such-module-moduleというエラーが発生する
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
end

# Pods for MovieReviewMVP

  target 'MovieReviewMVPTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MovieReviewMVPUITests' do
    # Pods for testing
  end

end

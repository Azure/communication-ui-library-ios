Pod::Spec.new do |spec|
  spec.name                 = "AzureCommunicationUIChat"
  spec.version              = "0.1.0"
  spec.summary              = "UI Library to quickly integrate Azure Communication Chat Services experiences into your applications."
  spec.homepage             = "https://github.com/Azure/communication-ui-library-ios"
  spec.license              = { :type => 'MIT' }
  spec.author               = 'Microsoft'
  spec.source               = { :git => 'https://github.com/Azure/communication-ui-library-ios.git', :tag => 'AzureCommunicationUIChat_0.1.0-beta1' }
  spec.module_name          = 'AzureCommunicationUIChat'
  spec.swift_version        = '5.6'

  spec.platform             = :ios, '14.0'

  spec.source_files         = 'AzureCommunicationUI/sdk/AzureCommunicationUIChat/Sources/**/*.swift'
  spec.resources            = 'AzureCommunicationUI/sdk/AzureCommunicationUIChat/Sources/**/*.{xcassets,strings}'
  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]": "arm64", "ENABLE_BITCODE": "NO"}
  spec.info_plist           = {'UILibrarySemVersion' => "#{spec.version}"}

  spec.dependency             'AzureCommunicationChat', '1.3.0'
  spec.dependency             'MicrosoftFluentUI/Avatar_ios', '0.8.9'
  spec.dependency             'MicrosoftFluentUI/BottomSheet_ios', '0.8.9'
  spec.dependency             'MicrosoftFluentUI/Button_ios', '0.8.9'
  spec.dependency             'MicrosoftFluentUI/PopupMenu_ios', '0.8.9'
  spec.dependency             'MicrosoftFluentUI/ActivityIndicator_ios', '0.8.9'
  spec.dependency             'MicrosoftFluentUI/AvatarGroup_ios', '0.8.9'
end

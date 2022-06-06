Pod::Spec.new do |spec|
  spec.name                 = "AzureCommunicationUICalling"
  spec.version              = "1.0.0-beta.2"
  spec.summary              = "UI Library to quickly integrate Azure Communication Calling Services experiences into your applications."
  spec.homepage             = "https://github.com/Azure/communication-ui-library-ios"
  spec.license              = { :type => 'MIT' }
  spec.author               = 'Microsoft'
  spec.source               = { :git => 'https://github.com/Azure/communication-ui-library-ios', :tag => 'AzureCommunicationUICalling_1.0.0-beta.2' }
  spec.module_name          = 'AzureCommunicationUICalling'
  spec.swift_version        = '5.6'

  spec.platform             = :ios, '14.0'

  spec.source_files         = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUICalling/**/*.swift'
  spec.resources            = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUICalling/**/*.{xcassets,strings}'

  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]": "arm64", "ENABLE_BITCODE": "NO"}
  
  spec.dependency             'AzureCommunicationCalling', '2.2.0-beta.1'
  spec.dependency             'MicrosoftFluentUI/Avatar_ios', '0.3.9'
  spec.dependency             'MicrosoftFluentUI/BottomSheet_ios', '0.3.9'
  spec.dependency             'MicrosoftFluentUI/Button_ios', '0.3.9'
  spec.dependency             'MicrosoftFluentUI/PopupMenu_ios', '0.3.9'
  spec.dependency             'MicrosoftFluentUI/ActivityIndicator_ios', '0.3.9'
end

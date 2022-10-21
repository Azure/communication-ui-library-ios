Pod::Spec.new do |s|
  s.name                  = 'AzureCommunicationUICommon'
  s.version               = '0.1.0'
  s.summary               = 'Common code functionality fore UI composites'

  s.description           = <<-DESC
This is an internal pod to provide the common implementation for all composites to use.
                       DESC
  s.homepage              = "https://github.com/Azure/communication-ui-library-ios"
  s.license               = { :type => 'MIT' }
  s.author                = 'Microsoft'
  s.source                = { :git => 'https://github.com/Azure/communication-ui-library-ios.git', :branch => 'emlyn/common-spi-packages' }
  s.module_name           = 'AzureCommunicationUICommon'
  s.swift_version         = '5.6'
  s.platform              = :ios, '14.0'
  s.ios.deployment_target = '14.0'
  s.source_files          = 'AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon/**/*'

end

Pod::Spec.new do |spec|
  spec.name = 'AzureCommunicationCalling'
  spec.version = '2.18.4'
  spec.summary = 'Azure Communication Calling Service client library for iOS.'
  spec.homepage = 'https://github.com/Azure/azure-sdk-for-ios'
  spec.author = 'Microsoft'
  spec.license = { :type => 'Commercial', :file => 'EULA.md' }
  spec.source = {
    :http => "https://github.com/Azure/Communication/releases/download/v#{spec.version}/AzureCommunicationCalling-#{spec.version}.zip",
    :sha256 => '7797f57a4be07fe66bb09cd16891f07f2f3795d5d1147043855c2a1cb77e24c1'
  }
  spec.platform = :ios, '12.0'
  spec.swift_version = '5.0'
  spec.source_files = 'AzureCommunicationCalling.xcframework/*/AzureCommunicationCalling.framework/Headers/*.h'
  spec.public_header_files = 'AzureCommunicationCalling.xcframework/*/AzureCommunicationCalling.framework/Headers/*.h'
  spec.vendored_frameworks = 'AzureCommunicationCalling.xcframework'
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  # Match the tested demo baseline; newer Common targets cannot compile with this binary's iOS 12 Swift interface.
  spec.dependency 'AzureCommunicationCommon', '~> 1.2.0'
end

Pod::Spec.new do |spec|
  spec.name = 'AzureCommunicationCalling'
  spec.version = '3.0.0'
  spec.summary = 'Azure Communication Calling Service client library for iOS.'
  spec.homepage = 'https://github.com/Azure/azure-sdk-for-ios'
  spec.author = 'Microsoft'
  spec.license = { :type => 'Commercial', :file => 'EULA.md' }
  spec.source = {
    :http => "https://github.com/Azure/Communication/releases/download/v#{spec.version}/AzureCommunicationCalling-#{spec.version}.zip",
    :sha256 => '56e84ebe75b9a12e3906a26c99ca0132c77f6ef57aad41d1d00a1b2b71f0c2a7'
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

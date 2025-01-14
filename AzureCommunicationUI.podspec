Pod::Spec.new do |s|
    s.name         = 'AzureCommunicationUI'
    s.version      = '1.0.0'
    s.summary      = 'A custom library for iOS.'
    s.description  = 'AzureCommunicationUI for custom buttons .'
    s.homepage     = 'https://github.com/souvickcse/communication-ui-library-ios'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { 'Your Name' => 'your.email@example.com' }
    s.source       = { :git => 'https://github.com/souvickcse/communication-ui-library-ios.git',:branch => "main", :tag => s.version.to_s }
    s.ios.deployment_target = '16.6'
    s.module_name          = 'AzureCommunicationUI'
  s.swift_version        = '5.8'
    s.source_files = 'AzureCommunicationUI/**/*'
   
  end
  
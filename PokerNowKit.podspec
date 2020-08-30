Pod::Spec.new do |s|
  s.name         = "PokerNowKit"
  s.version      = "0.0.9"
  s.summary      = "Shared framework of PokerNow.club log parsing code"
  s.homepage     = "https://github.com/pj4533/PokerNowKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = {
    "PJ Gray" => "pj4533@gmail.com"
  }
  s.source       = { :git => "git@github.com:pj4533/PokerNowKit.git", :tag => s.version }
  s.swift_version = "5.0"

  s.osx.deployment_target = "10.10"

  s.dependency 'CryptoSwift'
  
  s.source_files = "PokerNowKit/**/*.{h,swift}"
  s.requires_arc = true
end
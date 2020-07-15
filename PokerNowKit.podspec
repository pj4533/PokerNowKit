Pod::Spec.new do |s|
  s.name         = "PokerNowKit"
  s.version      = "0.0.4"
  s.summary      = "Shared framework of PokerNow.club log parsing code"
  s.homepage     = "https://github.com/pj4533/PokerNowKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = {
    "PJ Gray" => "pj4533@gmail.com"
  }
  s.source       = { :git => "https://github.com/pj4533/PokerNowKit", :tag => s.version }
  s.swift_version = [ "5.0", "4.2" ]

  s.osx.deployment_target = "10.10"

  s.source_files = "PokerNowKit/**/*.{h,swift}"
  s.requires_arc = true
end
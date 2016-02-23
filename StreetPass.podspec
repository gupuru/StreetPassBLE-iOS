Pod::Spec.new do |s|
  s.name                  = "StreetPass"
  s.version               = "0.0.1"
  s.summary               = "StreetPass library."
  s.homepage              = "https://github.com/gupuru/StreetPassBLE-iOS"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.platform              = :ios
  s.ios.deployment_target = '8.0'
  s.author                = { "gupuru" => "origami.magic789@gmail.com" }
  s.source                = { :git => "https://github.com/gupuru/StreetPassBLE-iOS.git", :tag => "#{s.version}" }
  s.source_files          = "StreetPass/*"
  s.social_media_url      = "https://twitter.com/gupuru"
  s.requires_arc          = true
end

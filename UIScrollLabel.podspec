version = "1.0.0"

Pod::Spec.new do |s|
  s.name         = "UIScrollLabel"
  s.version      = version
  s.summary      = "A subclass of UIScrollView which behaves like a marquee label. Uses UILabel and CADisplayLink under the hood."
  s.description  = <<-DESC
                   A subclass of `UIScrollView` which behaves like a marquee label. Uses `UILabel` and `CADisplayLink` under the hood.
                   DESC
  s.homepage     = "https://github.com/topLayoutGuide/UIScrollLabel"
  s.screenshots  = "https://raw.githubusercontent.com/topLayoutGuide/UIScrollLabel/master/screenshot.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Benjamin Yan Jurgis Dietzkis" => "ben.kawabata@gmail.com" }
  s.social_media_url   = "http://twitter.com/topLayoutGuide"
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/topLayoutGuide/UIScrollLabel.git", :tag => version }
  s.source_files  = "UIScrollLabel", "UIScrollLabel/**/*.{swift}"
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }	
end

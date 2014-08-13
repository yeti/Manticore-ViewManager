Pod::Spec.new do |s|
  s.name             = "MCViewManager"
  s.version          = "1.0.0"
  s.summary          = "MCViewManager is a view controller manager for iOS applications."
  s.description      = <<-DESC
                       MCViewManager is inspired by the Android Activity Lifecycle.
                       MCViewManager uses Activities to manage the View-Controllers. Activities can contain data and are associated with a single View-Controller when created. 
                       MCViewManager makes it easy to call an Activity and then deals with showing the associated view-controller with its data.
                       DESC
  s.homepage         = "https://github.com/YetiHQ/MCViewManager"
  s.license          = 'MIT'
  s.author           = { "philippe bertin" => "philippe.t.bertin@gmail.com", 
                         "Richard Fung" => "richard@yetihq.com",
                         "Anthony Scherba" => "tony@yetihq.com" }
  s.source           = { :git => "https://github.com/YetiHQ/MCViewManager.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/yetillc'

  s.platform     = :ios
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'

  s.frameworks = 'QuartzCore', 'AVFoundation', 'UIKit', 'Foundation'
end

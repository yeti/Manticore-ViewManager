Pod::Spec.new do |s|
  s.name             = "Manticore-ViewManager"
  s.version          = "1.0.0"
  s.summary          = "Manticore-ViewManager is a view controller manager for iOS applications."
  s.description      = <<-DESC
                       Manticore-ViewManager was inspired by the Android Activity Lifecycle.
                       Manticore-ViewManager uses Activities to manage the View-Controllers. Activities can contain data and are associated to a single View-Controller, when created.
                       Manticore-ViewManager makes it easy to call an Activity (and therefore load the associated View with its associated Data).
                       Manticore-ViewManager makes creation of any application easier and especially tabbed applications.
                       DESC
  s.homepage         = "https://github.com/YetiHQ/Manticore-ViewManager"
  s.license          = 'MIT'
  s.author           = { "philippe bertin" => "philippe.t.bertin@gmail.com", 
                         "Richard Fung" => "richard@yetihq.com",
                         "Anthony Scherba" => "tony@yetihq.com" }
  s.source           = { :git => "https://github.com/YetiHQ/Manticore-ViewManager", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/yetillc'

  s.platform     = :ios
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'

  s.frameworks = 'QuartzCore', 'AVFoundation', 'UIKit', 'Foundation'
end

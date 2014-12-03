Pod::Spec.new do |s|
  s.name         = "UAThirdPartyActivities"
  s.version      = "0.1"
  s.summary      = "A collection of UIActivity subclasses that can be dropped in to any UIActivityViewController for sharing or actions."
  s.description  = <<-DESC
					DESC
  s.homepage     = "https://github.com/unsignedapps/UAThirdPartyActivities/"
  s.license      = 'MIT'
  s.author       = { "Unsigned Apps" => "uatpa@unsignedapps.com" }
  s.source       = { :git => "https://github.com/unsignedapps/UAThirdPartyActivities.git", :tag => "0.1" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'ThirdPartyActivities/*.{h,m}', 'ThirdPartyActivities/Activities/*.{h,m}', 'UATPImages.xcassets', 'UATPLocalizable.strings'
end
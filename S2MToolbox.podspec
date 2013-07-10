Pod::Spec.new do |s|
  s.name         = "S2MToolbox"
  s.version      = "0.0.2"
  s.summary      = "iOS Categories."
  s.homepage     = "https://github.com/sinnerschrader-mobile/s2m-toolbox-ios"

  s.source       = { :git => 'https://github.com/sinnerschrader-mobile/s2m-toolbox-ios.git', :commit => '9a4273f8121b0a9a68b18cb999add6f4fd04bd72' } 
  s.authors      = { "François Benaiteau" => "francois.benaiteau@sinnerschrader-mobile.com" }
  s.platform     = :ios

  s.source_files = '**/*.{h,m}'
  s.requires_arc = true
  
  s.license	 = { :type => 'BSD-new', :file => 'LICENSE.txt' }
end

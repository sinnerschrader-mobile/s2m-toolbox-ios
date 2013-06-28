Pod::Spec.new do |s|
  s.name         = "S2MToolbox"
  s.version      = "0.0.1"
  s.summary      = "iOS Categories."
  s.homepage     = "https://github.com/sinnerschrader-mobile/s2m-toolbox-ios"

  s.source       = { :git => 'https://github.com/sinnerschrader-mobile/s2m-toolbox-ios.git', :commit => '366676481e178c31c84375daaab7efda135ee967' } 
  s.authors      = { "François Benaiteau" => "francois.benaiteau@sinnerschrader-mobile.com" }
  s.platform     = :ios

  s.source_files = '**/*.{h,m}'
  s.requires_arc = true

end

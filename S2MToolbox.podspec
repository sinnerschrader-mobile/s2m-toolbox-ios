Pod::Spec.new do |s|
  s.name         = "S2MToolbox"
  s.version      = "0.0.7"
  s.summary      = "iOS Categories."
  s.homepage     = "https://github.com/sinnerschrader-mobile/s2m-toolbox-ios"

  s.source       = { :git => 'https://github.com/sinnerschrader-mobile/s2m-toolbox-ios.git', :tag => s.version.to_s }
  s.authors      = { "François Benaiteau" => "francois.benaiteau@sinnerschrader-mobile.com" }
  s.platform     = :ios

  s.requires_arc = true

  s.license	 = { :type => 'BSD-new', :file => 'LICENSE.txt' }

  s.subspec 'Core' do |core|
    core.source_files = 'Foundation/*.{h,m}', 'UIKit/*.{h,m}'
  end

  s.subspec 'UnitTests' do |ut|
    ut.source_files  = 'Testing/UnitTests/*.{h,m}'
  end

  s.subspec 'Kiwi' do |ut|
    ut.source_files  = 'Testing/Kiwi/*.{h,m}'
  end

end

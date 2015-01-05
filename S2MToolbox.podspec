Pod::Spec.new do |s|
  s.name         = "S2MToolbox"
  s.version      = "0.1.0"
  s.summary      = "iOS Categories and more."
  s.homepage     = "https://github.com/sinnerschrader-mobile/s2m-toolbox-ios"

  s.source       = { :git => 'https://github.com/sinnerschrader-mobile/s2m-toolbox-ios.git', :tag => s.version.to_s }
  s.authors      = { "François Benaiteau" => "francois.benaiteau@sinnerschrader-mobile.com" }

  s.ios.deployment_target = '7.0'
  s.requires_arc = true 
  s.license	 = { :type => 'BSD-new', :file => 'LICENSE.txt' }

  s.default_subspecs = 'Foundation', 'UIKit'  

  s.subspec 'Foundation' do |f|
    f.source_files = 'Foundation/*.{h,m}'
  end

  s.subspec 'UIKit' do |ui|
    ui.source_files = 'UIKit/*.{h,m}'
  end
  
  s.subspec 'Kiwi' do |kiwi|
    kiwi.dependency 'Kiwi', '~>2.3.0'
    kiwi.frameworks = 'XCTest'
    kiwi.source_files  = 'Testing/Kiwi/*.{h,m}'
  end

  s.subspec 'QRCode' do |ut|
    ut.source_files  = 'QRCode/*.{h,m}'
  end
  
  s.subspec 'ShopFinder' do |ut|
    ut.source_files  = 'ShopFinder/*.{h,m}'
  end

  s.subspec 'HockeyApp' do |h|
    h.dependency 'HockeySDK'
    h.source_files = 'HockeyApp/*.{h,m}'
  end
end

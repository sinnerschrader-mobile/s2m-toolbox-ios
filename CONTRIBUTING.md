# CONTRIBUTING

* Source code is ARC only
* All methods have to be `s2m_` prefixed to avoid name clashes

## HOW TO

* clone a copy of the project
* if you use cocopods in your project, change the declaration to `pod 'S2MToolbox', :path => '<mypathtocodes2m-toolbox-ios>'`
* Commit your changes 

## For S2M Members

* Tag your commit and Update the version in 'S2MToolbox.podspec' accordingly (requires pushing rights
* Change back your project's podfile
* `pod update`

## For Others

* make a pull request with the name of your feature, i.e : `encryption`.

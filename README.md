S2M Toolbox for iOS
===================

[![Build Status](https://travis-ci.org/sinnerschrader-mobile/s2m-toolbox-ios.svg)](https://travis-ci.org/sinnerschrader-mobile/s2m-toolbox-ios)

Here is a collection of useful code that can be used through iOS projects.

**Note that all files are ARC only.**


# INSTALL

## via git submodule

* Add it by git

```
 git submodule add https://github.com/sinnerschrader-mobile/s2m-toolbox-ios submodules/s2m-toolbox-ios
```
* Add the files you need to your xcode project.

## via Cocoapods

* Add the following line to your podfile (includes all main categories in project):

```
pod 'S2MToolbox/Core', :podspec => 'https://raw.github.com/sinnerschrader-mobile/s2m-toolbox-ios/master/S2MToolbox.podspec'
```

For Categories for your tests:

```
pod 'S2MToolbox/Kiwi', :podspec => 'https://raw.github.com/sinnerschrader-mobile/s2m-toolbox-ios/master/S2MToolbox.podspec'
```

# Publishing

1. Update `S2MToolbox.podspec`
2. Run `pod lib lint` to check for errors and 
3. Tag the version
4. `pod trunk push`

More infos :
* http://guides.cocoapods.org/making/using-pod-lib-create.html
* http://guides.cocoapods.org/making/getting-setup-with-trunk
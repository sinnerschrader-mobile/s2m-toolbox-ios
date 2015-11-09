S2M Toolbox for iOS
===================

[![Build Status](https://travis-ci.org/sinnerschrader-mobile/s2m-toolbox-ios.svg?branch=master)](https://travis-ci.org/sinnerschrader-mobile/s2m-toolbox-ios)

Here is a collection of useful code that can be used through iOS projects.

**Note that all files are ARC only.**


# INSTALL

## via Cocoapods

* Each folder at the root of repository is a subspec (except Example of course).
* Add the following line to your podfile (includes default files to your project aka UIKit and Foundation):

```
pod 'S2MToolbox'
```

For Categories for your tests:

```
pod 'S2MToolbox/Kiwi'
```
## via git submodule

* Add it by git

```
 git submodule add https://github.com/sinnerschrader-mobile/s2m-toolbox-ios submodules/s2m-toolbox-ios
```
* Add the files you need to your xcode project.

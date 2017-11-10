//
//  Ourhdr.h
//  BlockTest_Dylib
//
//  Created by 梁伟 on 13-9-26.
//
//

#import <UIKit/UIKit.h>

#import <CoreGraphics/CoreGraphics.h>

#import "rocketbootstrap.h"

#import "interface.h"

#import "SimulateTouch.h"

#define PNGPATHFRONT @"/Applications/BlockTest/Documents"

#define PATH_PREFERENCE @"/var/mobile/Library/Preferences/com.lw.BlockTest.plist"

#define PATH_PREFERENCE_FOR_URLTest @"/var/mobile/Library/Preferences/com.lw.BlockTest_URLTest.plist"

#define appBundleId @"com.lw.BlockTest"

#define MMSATTACHPATH @"/Applications/BlockTest.app/Library/MMSTest.png"

#define RECEIVEDSMSPATH @"/var/mobile/Documents/com.softsec.smslog.plist"

#define RECEIVEDMMSPATH @"/var/mobile/Documents/com.softsec.mmslog.plist"
#define DEVICEINFO @"/var/mobile/Library/Preferences/com.softsec.DeviceInfo.plist"


extern "C" CGImageRef UIGetScreenImage();





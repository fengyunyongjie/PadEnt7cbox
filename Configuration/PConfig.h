//
//  PConfig.h
//  NetDisk
//
//  Created by fengyongning on 13-9-11.
//
//

#ifndef NetDisk_PConfig_h
#define NetDisk_PConfig_h
#define VERSION [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]
#define BUILD_VERSION @"6"
//#define BUILD_VERSION [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]
//#define APPSTORE_URL @"https://itunes.apple.com/us/app/hong-pan-shang-ye-ban/id737677663?ls=1&mt=8"
#define APPSTORE_URL @"itms-apps://itunes.apple.com/app/id808080594"
#define APPSTORE_URL6 @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=808080594"
#define UrlsessionDownload @"/com.apple.nsurlsessiond/Downloads/"
#define UrlsessionDownload7 @"/com.apple.nsnetworkd/" //7.0 sesion不同
#define BundleIdentifier [[NSBundle mainBundle] bundleIdentifier]
#endif
/**
 BUILD_VERSION 的值
 1.0.0 : 1
 1.0.1 : 2
 1.1.0 : 3
 1.1.1 : 4
 2.0.0 : 5
 2.1.0 : 6
*/
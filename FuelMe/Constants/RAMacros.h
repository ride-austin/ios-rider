#ifndef RAMacros_h
#define RAMacros_h

    #define kTextFieldMaxLength 255
    #define kiOSRiderDownloadURL  @"https://itunes.apple.com/us/app/ride-austin-non-profit-tnc/id1116489847?mt=8"
    #define kUniversalDownloadURL @"http://www.rideaustin.com/"

    #define IS_EMPTY(value) (((value) == (id)[NSNull null] || (value) == nil || ([(value) isKindOfClass:[NSString class]] && ([(id)(value) isEqualToString:@""] || [(id)(value) isEqualToString:@"<null>"]))) ? YES : NO)
    #define IS_NULL(original) ((original) == (id)[NSNull null])
    #define IS_NOT_NULL(original) (original && ![original isKindOfClass: [NSNull class]])
    #define IS_NULL2(original) (!IS_NOT_NULL(original))
    #define IF_NULL(original, replacement) (IS_NULL((original)) ? (replacement) : (original))
    #define SAFE_STRING(value) (IF_NULL((value), @""))

    // ******************* DEVICE INDENTIFICATION MACROS *****************//
    #define IS_IPAD             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    #define IS_IPHONE           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    #define IS_IPHONE4          (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
    #define IS_IPHONE4S         (IS_IPHONE && [[UIScreen mainScreen] nativeBounds].size.height == 960.0f)
    #define IS_IPHONE5          (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
    #define IS_IPHONE6          (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
    #define IS_IPHONE6PLUS      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
    #define IS_IPHONE_X      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0)
    #define IS_RETINA           ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

    #ifdef DEBUG
    #define DBLog(x, ...) NSLog(x, ## __VA_ARGS__);
    #else
    #define DBLog(x, ...)
    #endif

#endif /* RAMacros_h */

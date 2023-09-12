// RCTTVViewDebounceManager.h
#import <Foundation/Foundation.h>

@interface RCTTVViewDebounceManager : NSObject

+ (instancetype)sharedManager;

- (void)sendDebouncedEventWithTarget:(id)target selector:(SEL)selector;

@end

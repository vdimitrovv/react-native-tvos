// RCTTVViewDebounceManager.m
#import "RCTTVViewDebounceManager.h"

@interface RCTTVViewDebounceManager ()

@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;

@end

@implementation RCTTVViewDebounceManager

+ (instancetype)sharedManager {
    static RCTTVViewDebounceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)sendDebouncedEventWithTarget:(id)target selector:(SEL)selector {
    // Invalidate any previously scheduled dispatch_block_t.
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if (self.target == nil) {
        // If there's no ongoing timer, call the selector straight away and schedule
        // the timer, by the time the first timer runs, self.target will be nil
        // so it won't run the code twice
        [target performSelector:selector];
    }

    // Save the target and selector.
    self.target = target;
    self.selector = selector;

    // Schedule a new dispatch_block_t to be executed after a delay.
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        [weakSelf callTargetWithSelector];
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(performBlock:) withObject:block afterDelay:0.1 inModes:@[NSRunLoopCommonModes]];
    });
}

- (void)callTargetWithSelector {
    if (self.target && [self.target respondsToSelector:self.selector]) {
        [self.target performSelector:self.selector];
        self.target = nil;
        self.selector = nil;
    }
}

- (void)performBlock:(dispatch_block_t)block {
    block();
}

@end

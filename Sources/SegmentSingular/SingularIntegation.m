//
//  SingularIntegation.m
//  Segment-Singular-iOS
//
//  Created by Eyal Rabinovich on 29/05/2019.
//  Copyright © 2019 Singular Labs. All rights reserved.
//

#import "SingularIntegation.h"
@import Segment;

// Import Singular - trying different approaches for SPM compatibility
#if __has_include("Singular.h")
#import "Singular.h"
#import "SingularConfig.h"
#elif __has_include(<Singular/Singular.h>)
#import <Singular/Singular.h>
#import <Singular/SingularConfig.h>
#else
// If headers aren't found, define minimal interface to allow compilation
@interface Singular : NSObject
+ (void)setWrapperName:(NSString *)name andVersion:(NSString *)version;
+ (void)start:(id)config;
+ (void)setCustomUserId:(NSString *)customUserId;
+ (void)unsetCustomUserId;
+ (void)event:(NSString *)eventName;
+ (void)eventWithArgs:(NSString *)eventName args:(NSDictionary *)args;
+ (void)revenue:(NSString *)currency amount:(double)amount;
+ (void)customRevenue:(NSString *)eventName currency:(NSString *)currency amount:(double)amount;
+ (void)revenueWithArgs:(NSString *)currency amount:(double)amount productSKU:(NSString *)productSKU productName:(NSString *)productName productCategory:(NSString *)productCategory productQuantity:(int)productQuantity productPrice:(double)productPrice;
@end

@interface SingularConfig : NSObject
- (instancetype)initWithApiKey:(NSString *)apiKey andSecret:(NSString *)secret;
@property (nonatomic, assign) BOOL skAdNetworkEnabled;
@property (nonatomic, assign) BOOL manualSkanConversionManagement;
@property (nonatomic, copy) void (^conversionValueUpdatedCallback)(NSInteger);
@property (nonatomic, strong) NSNumber *waitForTrackingAuthorizationWithTimeoutInterval;
@end
#endif

#define SEGMENT_WRAPPER_NAME @"Segment"
#define SEGMENT_WRAPPER_VERSION @"1.2.0"

#define SEGMENT_REVENUE_KEY @"revenue"
#define SEGMENT_CURRENCY_KEY @"currency"
#define DEFAULT_CURRENCY @"USD"

@implementation SingularIntegation

static bool isSKANEnabled = NO;
static bool isManualMode = NO;
static void(^conversionValueUpdatedCallback)(NSInteger);
static int waitForTrackingAuthorizationWithTimeoutInterval = 0;
static bool isInitialized = NO;

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [super init];
    if (!self) {
        return self;
    }
    
    [Singular setWrapperName:SEGMENT_WRAPPER_NAME andVersion:SEGMENT_WRAPPER_VERSION];
    
    NSString* apiKey = [settings objectForKey:@"apiKey"];
    NSString* secret = [settings objectForKey:@"secret"];
    
    if (!apiKey || !secret){
        return nil;
    }
    
    SingularConfig* config = [[SingularConfig alloc] initWithApiKey:apiKey andSecret:secret];
    
    config.skAdNetworkEnabled = isSKANEnabled;
    config.manualSkanConversionManagement = isManualMode;
    config.conversionValueUpdatedCallback = conversionValueUpdatedCallback;
    config.waitForTrackingAuthorizationWithTimeoutInterval = @(waitForTrackingAuthorizationWithTimeoutInterval);
    
    [Singular start:config];
    
    isInitialized = YES;
    
    return self;
}

-(void)track:(SEGTrackPayload *)payload{
    
    if([[payload properties] objectForKey:SEGMENT_REVENUE_KEY] ||
       [[[payload properties] objectForKey:SEGMENT_REVENUE_KEY] doubleValue] != 0) {
        double revenue = [[[payload properties] objectForKey:SEGMENT_REVENUE_KEY] doubleValue];
        NSString* currency = DEFAULT_CURRENCY;
        
        if([[payload properties] objectForKey:SEGMENT_CURRENCY_KEY] &&
           [[[payload properties] objectForKey:SEGMENT_CURRENCY_KEY] length] > 0){
            currency = [[payload properties] objectForKey:SEGMENT_CURRENCY_KEY];
        }
        
        [Singular customRevenue:[payload event] currency:currency amount:revenue];
    } else {
        [Singular event:[payload event]];
    }
}

-(void)identify:(SEGIdentifyPayload *)payload{
    if([payload userId] && [[payload userId] length] > 0){
        [Singular setCustomUserId:[payload userId]];
    }
}

- (void)reset{
    [Singular unsetCustomUserId];
}

+ (void)setSKANOptions:(BOOL)skAdNetworkEnabled isManualSkanConversionManagementMode:(BOOL)manualMode withWaitForTrackingAuthorizationWithTimeoutInterval:(NSNumber* _Nullable)waitTrackingAuthorizationWithTimeoutInterval withConversionValueUpdatedHandler:(void(^_Nullable)(NSInteger))conversionValueUpdatedHandler {
    if (isInitialized) {
        NSLog(@"Singular Warning: setSKANOptions should be called before init");
    }

    isSKANEnabled = skAdNetworkEnabled;
    isManualMode = manualMode;
    conversionValueUpdatedCallback = conversionValueUpdatedHandler;
    waitForTrackingAuthorizationWithTimeoutInterval = waitTrackingAuthorizationWithTimeoutInterval ? [waitTrackingAuthorizationWithTimeoutInterval intValue] : 0;
}

@end

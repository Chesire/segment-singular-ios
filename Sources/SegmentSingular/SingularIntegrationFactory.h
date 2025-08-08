//
//  SingularIntegrationFactory.h
//  Segment-Singular-iOS
//
//  Created by Eyal Rabinovich on 29/05/2019.
//  Copyright © 2019 Singular Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Segment/SEGIntegrationFactory.h>

NS_ASSUME_NONNULL_BEGIN

@interface SingularIntegrationFactory : NSObject<SEGIntegrationFactory>
+ (instancetype)instance;
@end

NS_ASSUME_NONNULL_END

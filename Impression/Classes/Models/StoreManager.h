//
//  StoreManager.h
//  Impression
//
//  Created by Jason Fieldman on 4/15/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreManager : NSObject

@property (nonatomic, assign) BOOL saveMenuPurchased;

SINGLETON_INTR(StoreManager);

@end

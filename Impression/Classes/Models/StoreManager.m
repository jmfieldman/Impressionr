//
//  StoreManager.m
//  Impression
//
//  Created by Jason Fieldman on 4/15/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "StoreManager.h"

@implementation StoreManager

SINGLETON_IMPL(StoreManager);


- (BOOL)saveMenuPurchased {
	PersistentDictionary *dic = [PersistentDictionary dictionaryWithName:@"savemenu"];
	return [dic.dictionary[@"save"] boolValue];
}

- (void)setSaveMenuPurchased:(BOOL)saveMenuPurchased {
	PersistentDictionary *dic = [PersistentDictionary dictionaryWithName:@"savemenu"];
	dic.dictionary[@"save"] = @(YES);
	[dic saveToFile];
}


@end

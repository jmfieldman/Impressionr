//
//  StoreManager.h
//  Impression
//
//  Created by Jason Fieldman on 4/15/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SKProduct (printing)
- (NSString*) priceWithSymbol;
@end



@interface StoreManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, assign) BOOL       saveMenuPurchased;
@property (nonatomic, strong) SKProduct *saveMenuProduct;

SINGLETON_INTR(StoreManager);

- (void) updatePurchaseInfo;
- (void) restorePurchase;
- (void) initiatePurchase;

@end

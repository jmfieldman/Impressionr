//
//  StoreManager.m
//  Impression
//
//  Created by Jason Fieldman on 4/15/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "StoreManager.h"
#import "MainViewController.h"

@implementation SKProduct (pricing)
- (NSString*) priceWithSymbol {
	if ([self.price floatValue] == 0) return @"FREE";
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:self.priceLocale];
	return [numberFormatter stringFromNumber:self.price];
}
@end



@implementation StoreManager

SINGLETON_IMPL(StoreManager);

- (id) init {
	if ((self = [super init])) {
		/* Payments */
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

- (BOOL)saveMenuPurchased {
	PersistentDictionary *dic = [PersistentDictionary dictionaryWithName:@"savemenu"];
	return [dic.dictionary[@"save"] boolValue];
}

- (void)setSaveMenuPurchased:(BOOL)saveMenuPurchased {
	PersistentDictionary *dic = [PersistentDictionary dictionaryWithName:@"savemenu"];
	dic.dictionary[@"save"] = @(YES);
	[dic saveToFile];
}


- (void) updatePurchaseInfo {
	/* Don't need to do this if already purchased */
	if (self.saveMenuPurchased) return;
	
	SKProductsRequest *productsRequest;
	NSSet *productIdentifiers = [NSSet setWithObjects:
								 @"IMPR_SAVEMENU",
								 nil];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
	
	EXLog(PURCHASE, INFO, @"Sent in-app purchase item verification");
}

- (void) initiatePurchase {

	SKPayment *payment = [SKPayment paymentWithProduct:_saveMenuProduct];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	
	//[Flurry logEvent:@"InitiatePackPurchase" withParameters:@{ @"packId":packId }];

}

- (void) restorePurchase {
	EXLog(PURCHASE, INFO, @"In-app purchase restore");
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	
	//[Flurry logEvent:@"InitiateRestorePurchase"];
}



#pragma mark SKProductsRequestDelegate methods


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
		
	EXLog(PURCHASE, INFO, @"Received in-app purchase item verification");
	
    NSArray *products = response.products;
	for (SKProduct *product in products) {
		EXLog(PURCHASE, INFO, @"> %@: %@", product.productIdentifier, [product priceWithSymbol]);

		[[MainViewController sharedInstance] setPurchasePrice:[product priceWithSymbol]];
		_saveMenuProduct = product;
	}
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        EXLog(PURCHASE, ERR, @"> Invalid product id: %@" , invalidProductId);
    }
}



#pragma mark SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	
	for (SKPaymentTransaction *transaction in transactions) {
		
		EXLog(PURCHASE, INFO, @"Processing transaction for [%@]: %d", transaction.payment.productIdentifier, (int)transaction.transactionState);
		
		if (transaction.transactionState == SKPaymentTransactionStatePurchased ||
			transaction.transactionState == SKPaymentTransactionStateRestored) {
			
			EXLog(PURCHASE, ERR, @"> Transaction complete");
			[[MainViewController sharedInstance] showModalMessage:@"Save Menu Unlocked!"];
			self.saveMenuPurchased = YES;
			[Flurry logEvent:@"Purchase_Successful"];
				
		} else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
				
			EXLog(PURCHASE, ERR, @"> Transaction error: %@", transaction.error);
			[[MainViewController sharedInstance] showModalMessage:@"Purchase failed :("];
			
		}
			
		
		if (transaction.transactionState != SKPaymentTransactionStatePurchasing) {
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		}
		
	}

}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
	EXLog(PURCHASE, ERR, @"paymentQueue:restoreCompletedTransactionsFailedWithError: %@", error);
	
	[[MainViewController sharedInstance] showModalMessage:@"Restore failed :("];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	EXLog(PURCHASE, DBG, @"paymentQueueRestoreCompletedTransactionsFinished:");

	[[MainViewController sharedInstance] showModalMessage:@"Purchase Restored!"];
	self.saveMenuPurchased = YES;
	[Flurry logEvent:@"Restore_Successful"];
}


@end

//
//  SingleProductStore.m
//  SingleProduct
//
//  Created by Roee Kremer on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SingleProductStore.h"

@interface SingleProductStore()
-(void) setState:(NSUInteger)state;
-(void) singleProductStorePurchased:(SingleProductStore *)theStore;
-(void) singleProductStoreRestored:(SingleProductStore *)theStore;
-(void) singleProductStorePurchaseCanceled:(SingleProductStore *)theStore;
-(void) singleProductStorePurchaseFailed:(SingleProductStore *)theStore;
@end

@implementation SingleProductStore

@synthesize delegate,identifier,product;


+(SingleProductStore *)singleProductStore:(NSString *)theIdentifier delegate:(id<SingleProductStoreDelegate>) delegate {
    
    SingleProductStore *store = [[[SingleProductStore alloc] init] autorelease];
    store.delegate = delegate;
    store.identifier = theIdentifier;
   
    return store;
}

- (id)init {
	
	if (self = [super init]) {
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _state = [defaults integerForKey:@"SingleProductStoreState"];
        NSLog(@"init state: %i",_state);
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}


-(NSUInteger)state {
    return _state;
}

-(void) setState:(NSUInteger)state {
    if (_state<STORE_STATE_PRODUCT_PURCHASED) {
        _state = state;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:_state forKey:@"SingleProductStoreState"];
        [defaults synchronize];
        [delegate singleProductStoreStateChanged:self];
    }
    
}

-(void)check {
    
    if (_state<STORE_STATE_PRODUCT_PURCHASED) {
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: identifier]];
        request.delegate = self;
        
        [request start];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"productsRequest didReceiveResponse");
    
    self.product = nil;
    NSArray *myProduct = response.products;
    for (SKProduct *aProduct in myProduct) {
        NSLog(@"product: %@, desc: %@, price: %F, indentifier: %@",[aProduct localizedTitle],[aProduct localizedDescription],[[aProduct price] doubleValue],[aProduct productIdentifier]);
        self.product = aProduct;
    }
    
//    if (product) {
//        self.state = STORE_STATE_PRODUCT_EXIST; 
//    } else {
//        self.state = STORE_STATE_PRODUCT_DOES_NOT_EXIST;
//    }
    // populate UI
    [request autorelease];
}


-(BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

-(void)buy {
    
    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                self.state = STORE_STATE_PRODUCT_PURCHASED;
                [self singleProductStorePurchased:self];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
                self.state = STORE_STATE_PRODUCT_PURCHASED;
                [self singleProductStoreRestored:self];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
               
                if (transaction.error.code == SKErrorPaymentCancelled)
                {
                     [self singleProductStorePurchaseCanceled:self];
                    // Optionally, display an error here.
                } else
                {
                     [self singleProductStorePurchaseFailed:self];
                    NSLog(@"SKPaymentTransactionStateFailed: %@ because %@",transaction.error.localizedDescription,transaction.error.localizedFailureReason);
                }
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            
                
            default:
                break;
        }
    }
}

-(void)restore {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions]; 
}

/* in app store */







-(void) singleProductStorePurchased:(SingleProductStore *)theStore {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[theStore product] localizedTitle] message:NSLocalizedString(@"store purchased",@"Has been purchased successfully !")  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void) singleProductStoreRestored:(SingleProductStore *)theStore {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[theStore product] localizedTitle] message:NSLocalizedString(@"store restored",@"Has been restored successfully !")  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

-(void) singleProductStorePurchaseCanceled:(SingleProductStore *)theStore {
    
}

-(void) singleProductStorePurchaseFailed:(SingleProductStore *)theStore {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[theStore product] localizedTitle] message:NSLocalizedString(@"store failed",@"Purchase has been failed"	)  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}


@end

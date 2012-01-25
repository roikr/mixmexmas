//
//  StatelessStore.m
//  SingingCard
//
//  Created by Roee Kremer on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatelessStore.h"

@interface StatelessStore()
-(SKProduct*) productWithIdentifier:(NSString *)productIdentifier;
@end

@implementation StatelessStore

@synthesize delegate,products;


+(StatelessStore *)statelessStoreWithDelegate:(id<StatelessStoreDelegate>) delegate {
    
    StatelessStore *store = [[[StatelessStore alloc] init] autorelease];
    store.delegate = delegate;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:store];
    return store;
}



-(void)check:(NSSet *)productIdentifiers {
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"productsRequest didReceiveResponse");
    
    self.products = response.products;
    for (SKProduct *aProduct in products) {
        NSLog(@"product: %@, desc: %@, price: %F, indentifier: %@",[aProduct localizedTitle],[aProduct localizedDescription],[[aProduct price] doubleValue],[aProduct productIdentifier]);
    }
    
    [request autorelease];
}


-(BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

-(void)buy:(NSString *)productIdentifier  {
    
    for (SKProduct *aProduct in products) {
        if ([aProduct.productIdentifier isEqualToString:productIdentifier]) {
            [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:aProduct]];
            break;
        }
        
    }
    
    
}

-(SKProduct*) productWithIdentifier:(NSString *)productIdentifier {
    for (SKProduct *aProduct in products) {
        if ([aProduct.productIdentifier isEqualToString:productIdentifier]) {
            return aProduct;
        }
    }
    
    return nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        SKProduct *aProduct = [self productWithIdentifier:transaction.payment.productIdentifier];
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased: {
                [delegate statelessStoreProductReceived:transaction.payment.productIdentifier];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[aProduct localizedTitle] message:NSLocalizedString(@"store purchased",@"Has been purchased successfully !")  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            }   break;
            case SKPaymentTransactionStateRestored: {
                [delegate statelessStoreProductReceived:transaction.payment.productIdentifier];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[aProduct localizedTitle] message:NSLocalizedString(@"store restored",@"Has been restored successfully !")  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            }   break;
            case SKPaymentTransactionStateFailed:
                
                if (transaction.error.code == SKErrorPaymentCancelled)
                {
                    
                    // Optionally, display an error here.
                } else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[aProduct localizedTitle] message:NSLocalizedString(@"store failed",@"Purchase has been failed")  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release]; 
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

@end


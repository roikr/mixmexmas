//
//  StatelessStore.h
//  SingingCard
//
//  Created by Roee Kremer on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol StatelessStoreDelegate;

@interface StatelessStore : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver> {
    id<StatelessStoreDelegate> delegate;
    NSArray *products;
}


@property (nonatomic,retain) id<StatelessStoreDelegate> delegate;
@property (nonatomic,retain) NSArray *products;

+(StatelessStore *)statelessStoreWithDelegate:(id<StatelessStoreDelegate>) delegate;
-(void)check:(NSSet *)productIdentifiers;
-(void)buy:(NSString *)productIdentifier;
-(BOOL)canMakePayments;
-(IBAction)restore;

@end

@protocol StatelessStoreDelegate 
-(void) statelessStoreProductReceived:(NSString *)productIdentifier;

@end


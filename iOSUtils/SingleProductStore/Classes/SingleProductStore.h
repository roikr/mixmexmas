//
//  SingleProductStore.h
//  SingleProduct
//
//  Created by Roee Kremer on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

enum  {
    STORE_STATE_PRODUCT_NONE,
//    STORE_STATE_PRODUCT_DOES_NOT_EXIST,
//    STORE_STATE_PRODUCT_EXIST,
    STORE_STATE_PRODUCT_PURCHASED
};

@protocol SingleProductStoreDelegate;


@interface SingleProductStore : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver> {
    id<SingleProductStoreDelegate> delegate;
    NSUInteger _state;
    NSString *identifier;
    SKProduct *product;
    
}


@property (nonatomic,retain) id<SingleProductStoreDelegate> delegate;
@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) SKProduct *product;
@property (readonly) NSUInteger state;

+(SingleProductStore *)singleProductStore:(NSString *)identifier delegate:(id<SingleProductStoreDelegate>) delegate;
-(void)check;
-(void)buy;
-(BOOL)canMakePayments;
-(void)restore;

@end

@protocol SingleProductStoreDelegate 
-(void) singleProductStoreStateChanged:(SingleProductStore *)theStore;

@end

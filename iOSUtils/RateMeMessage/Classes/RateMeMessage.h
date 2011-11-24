//
//  RateMeMessage.h
//  Gogos
//
//  Created by Roee Kremer on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RateMeMessageDelegate;

@interface RateMeMessage : NSObject<UIAlertViewDelegate> {
    id<RateMeMessageDelegate> delegate;
    
    NSURL *url;
    NSTimer *timer;
    BOOL didFire;
    NSTimeInterval delay;
    
    NSUInteger counter;
}

@property (nonatomic,retain) id<RateMeMessageDelegate> delegate;
@property (nonatomic,retain) NSURL *url;
@property (nonatomic,retain) NSTimer *timer;
@property NSTimeInterval delay;
@property NSUInteger counter;


+(RateMeMessage*) rateMeMessage:(NSString *)theURL firstDelay:(NSTimeInterval)firstDelay repeatedDelay:(NSTimeInterval)repeatedDelay delegate:(id<RateMeMessageDelegate>)theDelegate;
-(void) show;
-(void) becomeActive;
-(void) resignActive;





@end

@protocol RateMeMessageDelegate 

-(void) rateMeMessageDelegateDidFire:(RateMeMessage *)theMessage;
-(void) rateMeMessageDelegateDone:(RateMeMessage *)theMessage;

@end
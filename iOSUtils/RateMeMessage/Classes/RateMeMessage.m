//
//  RateMeMessage.m
//  Gogos
//
//  Created by Roee Kremer on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RateMeMessage.h"

@interface RateMeMessage(PrivateMethods) 
-(void) fire;
@end


@implementation RateMeMessage
@synthesize delegate;
@synthesize url;
@synthesize timer;
@synthesize delay;

//#define RATE_ME_MESSAGE_RESET

+(RateMeMessage*) rateMeMessage:(NSString *)theURL firstDelay:(NSTimeInterval)firstDelay repeatedDelay:(NSTimeInterval)repeatedDelay delegate:(id<RateMeMessageDelegate>)theDelegate{
    RateMeMessage *message = nil;
    
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

#ifdef RATE_ME_MESSAGE_RESET
    [defaults removeObjectForKey:@"MeRated"];
    [defaults synchronize];
#endif
    
    
    if (![defaults boolForKey:@"MeRated"]) {
        message = [[[RateMeMessage alloc] init] autorelease];
        message.url = [NSURL URLWithString:theURL];
        message.delegate = theDelegate;
        message.delay = repeatedDelay;
        message.timer =  [NSTimer scheduledTimerWithTimeInterval:firstDelay target:message selector:@selector(fire) userInfo:nil repeats:NO];
        
    }
    return message;
}

- (id)init {
	
	if (self = [super init]) {
	} return self;
}

- (void)dealloc
{
    [timer release];
    [url release]; 
    [super dealloc];
}

- (void)becomeActive {
    if (timer==nil) {
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(fire) userInfo:nil repeats:YES];	
    }
    
}

- (void) resignActive {
    [timer invalidate];
    timer = nil;
}

-(void)fire {
    if (!didFire) {
        didFire = YES;
        self.timer = nil;
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(fire) userInfo:nil repeats:YES];
    }
    [delegate rateMeMessageDelegateDidFire:self];
}

-(void) show {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"rate title",@"Do you like this app?") message:NSLocalizedString(@"rate message",@"Please rate it in the App Store") delegate:self  cancelButtonTitle:NSLocalizedString(@"rate no",@"No thanks")  otherButtonTitles: NSLocalizedString(@"rate yes",@"Rate it now"),nil];
    [alert show];
    [alert release];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView: %i",buttonIndex);
    
    if (buttonIndex == 1) {
        [timer invalidate];
        self.timer = nil;
        if (![[UIApplication sharedApplication] openURL:url]) {
            NSLog(@"Failed to open url: %@",url);
        } else {
            [delegate rateMeMessageDelegateDidRate:self];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"MeRated"];
            [defaults synchronize];
        }
    } 
}



@end

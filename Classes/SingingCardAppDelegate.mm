//
//  SingingCardAppDelegate.m
//  SingingCard
//
//  Created by Roee Kremer on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SingingCardAppDelegate.h"
#import "MainViewController.h"
#import "ShareViewController.h"

#import "ShareManager.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#include "Constants.h"
#include "testApp.h"

#include "EAGLView.h"
#include "RKMacros.h"
#import "PopupMessage.h"
#import "SingingCardKeys.h"

#ifdef _FLURRY
#import "FlurryAnalytics.h"
#endif

@interface SingingCardAppDelegate()

@end

@implementation SingingCardAppDelegate

@synthesize window;
@synthesize eAGLView;


@synthesize mainViewController;
@synthesize shareViewController;
@synthesize infoViewController;
@synthesize playerViewController;


@synthesize lastSavedVersion;
@synthesize shareManager;

@synthesize imageView;

#define PLAY_INTRO


#ifdef _FLURRY
void uncaughtExceptionHandler(NSException *exception) { 
	[FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception]; 
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLog(@"application didFinishLaunchingWithOptions");
		
#ifdef _FLURRY
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAnalytics startSession:kFlurryApiKey]; 
#endif

	
	self.shareManager = [ShareManager shareManager];
	
	self.window.rootViewController = self.mainViewController;
	[self.window makeKeyAndVisible];
    
#ifdef PLAY_INTRO
    [playerViewController setDelegate:self];
    [playerViewController loadAssetFromURL:[[NSBundle mainBundle] URLForResource:@"OPENING_MOV_IPHONE" withExtension:@"m4v"]]; 
    //		playerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    switch([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPhone: 
            imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,-M_PI/2.0);
            imageView.center = CGPointMake(240.0, 160.0);
            
            break;
        case UIUserInterfaceIdiomPad:
            imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,-M_PI/2.0);
            imageView.center = CGPointMake(512.0, 384.0);
            break;
            
    }
    
    
    [playerViewController.view addSubview:imageView];
     [self.mainViewController presentModalViewController:playerViewController animated:NO];
    
#else

    self.OFSAptr->startAudio();
    [PopupMessage popupMessage:kPopupMessageURL];

#endif

	[self.eAGLView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:0];
	RKLog(@"application didFinishLaunchingWithOptions finished");
	return YES;
}

-(testApp*) OFSAptr {
    return self.eAGLView.OFSAptr;
}

- (NSString *)getCurrentCardTag {
    return  [NSString stringWithCString:self.OFSAptr->citer->tag.c_str() encoding:[NSString defaultCStringEncoding]];
}

-(void) AVPlayerLayerIsReadyForDisplay:(AVPlayerViewController*)controller {
    [imageView removeFromSuperview];
//    

}

-(void) AVPlayerViewControllerDone:(AVPlayerViewController*)controller {
    RKLog(@"AVPlayerViewControllerDone");
           
    self.OFSAptr->startAudio();
    [PopupMessage popupMessage:kPopupMessageURL];
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    RKLog(@"applicationDidBecomeActive");
	/*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    
	
    self.OFSAptr->becomeActive();
	
    [self.eAGLView startAnimation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		RKLog(@"update loop started");
		
		while ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
			if (self.OFSAptr) {
				
				//OFSAptr->update(); // also update bNeedDisplay - roikr: done in drawFrame
				
				if (self.OFSAptr->bNeedDisplay) {
					dispatch_async(dispatch_get_main_queue(), ^{
						
						[mainViewController updateViews];
					});
					self.OFSAptr->bNeedDisplay = false; // this should stay out off the main view async call
				}
                
#ifdef _FLURRY
                if (self.OFSAptr->bSongPlayed) {
                    
                    if (ofGetElapsedTimeMillis() - self.OFSAptr->playTime>LONG_PLAY) {
                        self.OFSAptr->bSongPlayed = false;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [FlurryAnalytics logEvent:@"PLAY" withParameters:[NSDictionary dictionaryWithObject:[self getCurrentCardTag] forKey:@"CARD"]];
                        }); 
                    }

                }
#endif
				
			}
			
		}
		RKLog(@"update loop exited");		
	});
    
    
	
    RKLog(@"applicationDidBecomeActive - ended");
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    RKLog(@"applicationWillResignActive");
	[self.eAGLView stopAnimation];
    self.OFSAptr->resignActive();
}



- (void)applicationWillTerminate:(UIApplication *)application
{
     RKLog(@"applicationWillTerminate");
	[self.eAGLView stopAnimation]; 
}

- (void)beginInterruption {
	RKLog(@"beginInterruption");
	
    
    self.OFSAptr->setSongState(SONG_IDLE);
    self.OFSAptr->soundStreamStop();
	
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
	RKLog(@"endInterruptionWithFlags: %u",flags);
	
	if (flags && AVAudioSessionInterruptionFlags_ShouldResume) {
		NSError *activationError = nil;
		[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
		RKLog(@"audio session activated");
		
        self.OFSAptr->soundStreamStart();
		
		
	}
	
}





- (void)applicationDidEnterBackground:(UIApplication *)application
{
     
	
	RKLog(@"applicationDidEnterBackground");
	
	[shareManager applicationDidEnterBackground];
    
//    if (mainViewController.modalViewController == (UIViewController*) infoViewController) {
//        [mainViewController dismissModalViewControllerAnimated:NO];
//    }
    
    
    
    if (mainViewController.modalViewController && mainViewController.modalViewController != (UIViewController*) playerViewController) {
        [mainViewController dismissModalViewControllerAnimated:NO];
    }
    
	
	// Handle any background procedures not related to animation here.
	if (self.OFSAptr) {
		self.OFSAptr->suspend();
	}
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    RKLog(@"applicationWillEnterForeground");
	// Handle any foreground procedures not related to animation here.
	
    self.OFSAptr->resume();
    
    if (mainViewController.modalViewController && mainViewController.modalViewController == (UIViewController*) playerViewController) {
        [playerViewController.player seekToTime:CMTimeMake(0, 1)];
        [playerViewController.player play];
    } else {
        
        [PopupMessage popupMessage:kPopupMessageURL];
    }
}

- (void)dealloc
{
    [eAGLView release];
	[mainViewController release];

    [window release];
    
    [super dealloc];
}







@end

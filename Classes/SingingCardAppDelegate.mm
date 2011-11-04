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

//#import "AVPlayerDemoPlaybackViewController.h"

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#include "Constants.h"
#include "testApp.h"

#include "EAGLView.h"
#include "RKMacros.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif

@interface SingingCardAppDelegate()

@end

@implementation SingingCardAppDelegate

@synthesize window;
@synthesize eAGLView;


@synthesize mainViewController;
@synthesize shareViewController;


@synthesize lastSavedVersion;
@synthesize shareManager;

//#define PLAY_INTRO


#ifdef _FLURRY
void uncaughtExceptionHandler(NSException *exception) { 
	[FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception]; 
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLog(@"application didFinishLaunchingWithOptions");
		
#ifdef _FLURRY
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAPI startSession:@"QHB9XPQ4RUUGDYIS7H4Z"]; 
#endif

	
	self.shareManager = [ShareManager shareManager];
	
	self.window.rootViewController = self.mainViewController;
	[self.window makeKeyAndVisible];
    
#ifdef PLAY_INTRO
    AVPlayerViewController *playerViewController =[[AVPlayerViewController alloc] initWithNibName:@"AVPlayerViewController" bundle:nil];
    [playerViewController setDelegate:self];
    [playerViewController loadAssetFromURL:[[NSBundle mainBundle] URLForResource:@"SHANA_DEMO_IPHONE" withExtension:@"m4v"]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,-M_PI/2.0);
    imageView.center = CGPointMake(240.0, 160.0);
    [playerViewController.view addSubview:imageView];
    [imageView release];
    //		playerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.mainViewController presentModalViewController:playerViewController animated:NO];
    [playerViewController release];
#endif

	[self.eAGLView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:0];
	RKLog(@"application didFinishLaunchingWithOptions finished");
	return YES;
}

-(testApp*) OFSAptr {
    return self.eAGLView.OFSAptr;
}

-(NSUInteger) getCurrentCardNumber {
    
    return distance(self.OFSAptr->cards.begin(),self.OFSAptr->citer);
}

-(void) AVPlayerLayerIsReadyForDisplay:(AVPlayerViewController*)controller {
	for (UIView *view in [controller.view subviews]) {
		if ([view isKindOfClass:[UIImageView class]]) {
			[view removeFromSuperview];
		}
	}
}

-(void) AVPlayerViewControllerDone:(AVPlayerViewController*)controller {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    RKLog(@"applicationDidBecomeActive");
	/*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	

	self.OFSAptr->soundStreamStart();
    
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
                            [FlurryAPI logEvent:@"PLAY" withParameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i",[self getCurrentCardNumber]] forKey:@"CARD"]];
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
    self.OFSAptr->soundStreamStop();
	
}



- (void)applicationWillTerminate:(UIApplication *)application
{
     RKLog(@"applicationWillTerminate");
	[self.eAGLView stopAnimation]; 
}

- (void)beginInterruption {
	RKLog(@"beginInterruption");
	
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
	
	// Handle any background procedures not related to animation here.
	if (self.OFSAptr) {
		self.OFSAptr->suspend();
	}
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    RKLog(@"applicationWillEnterForeground");
	// Handle any foreground procedures not related to animation here.
	if (self.OFSAptr) {
		self.OFSAptr->resume();
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

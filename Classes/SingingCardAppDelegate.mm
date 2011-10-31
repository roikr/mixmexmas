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
#include "ofMainExt.h"
#include "EAGLView.h"
#include "RKMacros.h"

@implementation SingingCardAppDelegate

@synthesize window;
@synthesize eAGLView;


@synthesize mainViewController;
@synthesize shareViewController;

@synthesize OFSAptr;
@synthesize lastSavedVersion;
@synthesize shareManager;

#define PLAY_INTRO

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLog(@"application didFinishLaunchingWithOptions");
	setiPhoneDataPath();	
	
	self.shareManager = [ShareManager shareManager];
	
	self.window.rootViewController = self.mainViewController;
	[self.window makeKeyAndVisible];
		
	[self.eAGLView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:0];
	RKLog(@"application didFinishLaunchingWithOptions finished");
	return YES;
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
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		RKLog(@"update loop started");
		
		while ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
			if (OFSAptr) {
				
				//OFSAptr->update(); // also update bNeedDisplay
				
				if (OFSAptr->bNeedDisplay) {
					dispatch_async(dispatch_get_main_queue(), ^{
						
						[mainViewController updateViews];
						
						
						
						
					});
					OFSAptr->bNeedDisplay = false; // this should stay out off the main view async call
				}
				
			}
			
		}
		RKLog(@"update loop exited");		
	});
	
		
	if (!OFSAptr) {
		
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
		self.OFSAptr = new testApp;
		OFSAptr->setup();
	} else {
		OFSAptr->soundStreamStart();
	}

	[self.eAGLView startAnimation];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    RKLog(@"applicationWillResignActive");
	[self.eAGLView stopAnimation];
	
	if (OFSAptr) {
		OFSAptr->soundStreamStop();
	}
}



- (void)applicationWillTerminate:(UIApplication *)application
{
     RKLog(@"applicationWillTerminate");
	[self.eAGLView stopAnimation]; 
}

- (void)beginInterruption {
	RKLog(@"beginInterruption");
	if (OFSAptr) {
		OFSAptr->soundStreamStop();
	}
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
	RKLog(@"endInterruptionWithFlags: %u",flags);
	
	if (flags && AVAudioSessionInterruptionFlags_ShouldResume) {
		NSError *activationError = nil;
		[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
		RKLog(@"audio session activated");
		if (OFSAptr) {
			OFSAptr->soundStreamStart();
		}
		
	}
	
}





- (void)applicationDidEnterBackground:(UIApplication *)application
{
     
	
	RKLog(@"applicationDidEnterBackground");
	
	[shareManager applicationDidEnterBackground];
	
	// Handle any background procedures not related to animation here.
	if (OFSAptr) {
		OFSAptr->suspend();
	}
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    RKLog(@"applicationWillEnterForeground");
	// Handle any foreground procedures not related to animation here.
	if (OFSAptr) {
		OFSAptr->resume();
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

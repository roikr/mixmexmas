//
//  ConvertToVideoAppDelegate.m
//  ConvertToVideo
//
//  Created by Roee Kremer on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConvertToVideoAppDelegate.h"
#import "ConvertToVideoViewController.h"

@implementation ConvertToVideoAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

		
		
	
	return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    [viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end

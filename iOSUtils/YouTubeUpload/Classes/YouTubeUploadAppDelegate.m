//
//  YouTubeUploadAppDelegate.m
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploadAppDelegate.h"
#import "YouTubeUploadViewController.h"

@implementation YouTubeUploadAppDelegate

@synthesize window;
//@synthesize navigationController;
@synthesize uploader;
@synthesize controller;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
   // [window addSubview:navigationController.view];
   
	//YouTubeUploadViewController * controller = (YouTubeUploadViewController*)navigationController.visibleViewController;
	self.uploader = [YouTubeUploader youTubeUploader:nil];
	[uploader addDelegate:self];
	
	[window makeKeyAndVisible];
	
	controller.uploader = uploader;
	controller.videoTitle = @"kremer the cat";
	controller.descriptionView.text = @"testing";
	controller.videoPath = [[NSBundle mainBundle] pathForResource:@"BOY" ofType:@"mov"];
	
		
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"applicationWillResignActive");
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
	NSLog(@"applicationDidEnterBackground");
	/*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
   NSLog(@"applicationWillEnterForeground");
	/*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
	/*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"applicationWillTerminate");
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    //[navigationController release];
	[uploader release];
	[controller release];
    [window release];
    [super dealloc];
}


- (void) youTubeUploaderDidFinishUploading:(YouTubeUploader *)theUploader  withURL:(NSURL*) theUrl {
	NSLog(@"link: %@",[theUrl absoluteString]);
}


@end

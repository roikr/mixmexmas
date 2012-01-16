//
//  AppDelegate.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PopupMessage.h"
#import "ofMainExt.h"
#import "ofxiPhoneExtras.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize popupMessage;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}






- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    ofSetDataPathRoot(ofxiPhoneGetDocumentsDirectory());
//    ofxDeleteFile(ofxiPhoneGetDocumentsDirectory()+"popups_state.xml");
//    ofxDeleteFile(ofxiPhoneGetDocumentsDirectory()+"timeline.xml");
//    ofxCopyFile(ofxNSStringToString([[NSBundle mainBundle] resourcePath])+"/timeline.xml", ofxiPhoneGetDocumentsDirectory()+"timeline.xml");
    
    ofSetDataPathRoot(ofxNSStringToString([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])+'/');
    self.popupMessage= [PopupMessage popupMessage:@"http://www.lofipeople.com/mixmexmas"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
   [popupMessage unload];
   
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [popupMessage load];
    
//    self.messageParser = [MessageParser messageParser];
//    messageParser.delegate = self;
//    NSURL *url = ;
//    [messageParser downloadAndParse:url];
    
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"title" message:@"message" delegate:self cancelButtonTitle:@"No, thanks !" otherButtonTitles:@"bring it !" , nil];
//    [alertView show];
//    [alertView release];
    
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
-(void)MessageParserDelegateParsed:(MessageParser *)parser {
    [parser.alertView setDelegate:self];
    [parser.alertView show];
 //   [alertView release];
}
*/
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView: %i",buttonIndex);
//    NSLog(@"button: %i, link: %@",buttonIndex,[messageParser.links objectAtIndex:buttonIndex]);
//    self.messageParser = nil;
}


@end

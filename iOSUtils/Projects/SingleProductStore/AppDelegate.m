//
//  AppDelegate.m
//  SingleProductStore
//
//  Created by Roee Kremer on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

NSString * const kMyFeatureIdentifier = @"ExpansionTest";


@implementation AppDelegate

@synthesize window = _window;
@synthesize store;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.store = [SingleProductStore singleProductStore:kMyFeatureIdentifier delegate:self];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
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
    NSLog(@"applicationDidBecomeActive");
    [store check];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void) singleProductStoreStateChanged:(SingleProductStore *)theStore {
    NSLog(@"singleProductStoreStateChanged: %i",[theStore state]);
    switch ([theStore state]) {
        case STORE_STATE_PRODUCT_DOES_NOT_EXIST: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Store" message:@"No Product"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } break;
            
        case STORE_STATE_PRODUCT_EXIST: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[theStore product] localizedTitle] message:[[theStore product] localizedDescription] delegate:self cancelButtonTitle:@"Bye" otherButtonTitles:@"Buy", nil];
            [alert show];
            [alert release];
        } break;
            
        case STORE_STATE_PRODUCT_PURCHASED: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[theStore product] localizedTitle] message:@"Purchased"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } break;
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            if ([store canMakePayments]) {
                [store buy];
            }
            break;
            
        default:
            break;
    }
}

@end

//
//  SingingCardAppDelegate.h
//  SingingCard
//
//  Created by Roee Kremer on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPlayerViewController.h"


@class MainViewController;
@class ShareViewController;

@class ShareManager;
@class EAGLView;
class testApp;

@interface SingingCardAppDelegate : NSObject <UIApplicationDelegate,AVPlayerViewControllerDelegate> {
    UIWindow *window;
	EAGLView *eAGLView;
    MainViewController *mainViewController;
	ShareViewController *shareViewController;
		
	testApp *OFSAptr;
	
	ShareManager *shareManager;
	NSInteger lastSavedVersion;
	
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic,retain)  IBOutlet EAGLView *eAGLView;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet ShareViewController *shareViewController;


@property testApp *OFSAptr;

@property (nonatomic, retain) ShareManager *shareManager;
@property NSInteger lastSavedVersion;

@end



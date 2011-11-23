//
//  SingingCardAppDelegate.h
//  SingingCard
//
//  Created by Roee Kremer on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPlayerViewController.h"
#import "RateMeMessage.h"


@class MainViewController;
@class ShareViewController;
@class InfoViewController;
@class AVPlayerViewController;

@class ShareManager;
@class EAGLView;
class testApp;


@interface SingingCardAppDelegate : NSObject <UIApplicationDelegate,AVPlayerViewControllerDelegate,RateMeMessageDelegate> {
    UIWindow *window;
	EAGLView *eAGLView;
    MainViewController *mainViewController;
	ShareViewController *shareViewController;
    InfoViewController *infoViewController;
    AVPlayerViewController *playerViewController;
		
	ShareManager *shareManager;
	NSInteger lastSavedVersion;
    
    UIImageView *imageView;
    
    RateMeMessage *message;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic,retain)  IBOutlet EAGLView *eAGLView;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet ShareViewController *shareViewController;
@property (nonatomic, retain) IBOutlet InfoViewController *infoViewController;
@property (nonatomic, retain) IBOutlet AVPlayerViewController *playerViewController;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) RateMeMessage *message;


@property (nonatomic, retain) ShareManager *shareManager;
@property NSInteger lastSavedVersion;

-(testApp*) OFSAptr;
- (NSString *)getCurrentCardTag;
@end



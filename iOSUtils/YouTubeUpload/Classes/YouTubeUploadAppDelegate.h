//
//  YouTubeUploadAppDelegate.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTubeUploader.h"

@class YouTubeUploadViewController;

@interface YouTubeUploadAppDelegate : NSObject <UIApplicationDelegate,YouTubeUploaderDelegate> {
    UIWindow *window;
    //UINavigationController *navigationController;
	YouTubeUploadViewController *controller;
	
	YouTubeUploader *uploader;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) YouTubeUploader *uploader;
@property (nonatomic, retain) IBOutlet YouTubeUploadViewController *controller;

@end


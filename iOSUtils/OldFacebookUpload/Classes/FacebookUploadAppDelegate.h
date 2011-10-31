//
//  FacebookUploadAppDelegate.h
//  FacebookUpload
//
//  Created by Roee Kremer on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookUploader.h"

@class FacebookUploadViewController;

@interface FacebookUploadAppDelegate : NSObject <UIApplicationDelegate,FacebookUploaderDelegate> {
    UIWindow *window;
	FacebookUploadViewController *controller;
	FacebookUploader *uploader;
	
	
	
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FacebookUploadViewController *controller;
@property (nonatomic, retain) FacebookUploader *uploader;

@end
 

//
//  RKUBackgroundTask.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RKUBackgroundTask : NSObject {
	UIBackgroundTaskIdentifier bgTask;
	NSTimeInterval lastTimeRemaining;
}

@property NSTimeInterval lastTimeRemaining;

+ (RKUBackgroundTask *) backgroundTask;
+ (BOOL) isBackground;

- (void) update;
- (void) finish;
@end

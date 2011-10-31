//
//  RKUBackgroundTask.m
//  YouTubeUpload
//
//  Created by Roee Kremer on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RKUBackgroundTask.h"



@implementation RKUBackgroundTask

@synthesize lastTimeRemaining;

+ (RKUBackgroundTask *) backgroundTask {
	return [[[RKUBackgroundTask alloc] init] autorelease];
}

+ (BOOL) isBackground {
	UIApplication*    app = [UIApplication sharedApplication];
	return app.applicationState == UIApplicationStateBackground;
}

- (id)init {
	
	if (self = [super init]) {
		NSLog(@"RKUBackgroundTask::init");
		
		UIApplication*    app = [UIApplication sharedApplication];
		
		bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
			[app endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		}];
		
		[self update];
		
		
		
		
	}
	return self;
}

- (void) update {
	UIApplication*    app = [UIApplication sharedApplication];
	lastTimeRemaining = [app backgroundTimeRemaining];
	if (app.applicationState == UIApplicationStateBackground) {
		NSLog(@"RKUBackgroundTask::update time: %qu",lastTimeRemaining);
	} else {
		NSLog(@"RKUBackgroundTask::update time: unlimited, state: %i",app.applicationState);
	}

	
}



- (void) finish {
	NSLog(@"RKUBackgroundTask::finish");
	if (bgTask!=UIBackgroundTaskInvalid) {
		UIApplication*    app = [UIApplication sharedApplication];
		[app endBackgroundTask:bgTask];
		bgTask = UIBackgroundTaskInvalid;
	}
	
}

@end

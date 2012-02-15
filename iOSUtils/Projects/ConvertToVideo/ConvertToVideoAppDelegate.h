//
//  ConvertToVideoAppDelegate.h
//  ConvertToVideo
//
//  Created by Roee Kremer on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConvertToVideoViewController;

@interface ConvertToVideoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ConvertToVideoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ConvertToVideoViewController *viewController;

@end


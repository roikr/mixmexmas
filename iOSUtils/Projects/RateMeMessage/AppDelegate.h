//
//  AppDelegate.h
//  RateMeMessage
//
//  Created by Roee Kremer on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateMeMessage.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,RateMeMessageDelegate> {
    RateMeMessage *message;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) RateMeMessage *message;
@end

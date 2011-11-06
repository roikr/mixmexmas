//
//  AppDelegate.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageParser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,MessageParserDelegate,UIAlertViewDelegate> {
    MessageParser *messageParser;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) MessageParser *messageParser;

@end

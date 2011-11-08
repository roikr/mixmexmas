//
//  AppDelegate.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupMessage;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate> {
    PopupMessage *popupMessage;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) PopupMessage *popupMessage;

@end

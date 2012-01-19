//
//  AppDelegate.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupMessage.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,PopupMessageDelegate> {
    PopupMessage *popupMessage;
    UISwitch *button;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) PopupMessage *popupMessage;
@property (nonatomic, retain) UISwitch *button;



@end

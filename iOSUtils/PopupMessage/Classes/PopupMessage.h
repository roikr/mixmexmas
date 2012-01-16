//
//  PopupMessage.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageLoader.h"
#include "ofxPopupMessages.h"


@interface PopupMessage : NSObject<MessageLoaderDelegate,UIAlertViewDelegate> {
   
    NSString *url;
    MessageLoader *loader;
    NSTimer *timer;
    UIAlertView *view; // since 4.0 we need to keep it to manage when going background while alert open...
    
    ofxPopupMessages messages;
}

@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) MessageLoader *loader;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) UIAlertView *view;

+(PopupMessage*) popupMessage:(NSString *)theURL;
-(void) load;
-(void) unload;

@end



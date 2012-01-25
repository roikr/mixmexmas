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

@protocol PopupMessageDelegate; 

@interface PopupMessage : NSObject<MessageLoaderDelegate,UIAlertViewDelegate> {
    
    id<PopupMessageDelegate> delegate;
    NSString *url;
    MessageLoader *loader;
    UIAlertView *view; // since 4.0 we need to keep it to manage when going background while alert open...
    NSTimer *timer;
   
    ofxPopupMessages popup;
    
    BOOL startMessage;
}

@property (nonatomic,retain) id<PopupMessageDelegate> delegate;
@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) MessageLoader *loader;
@property (nonatomic,retain) UIAlertView *view;
@property (nonatomic,retain) NSTimer *timer;
@property BOOL messageDisplayed;

+(PopupMessage*) popupMessage:(NSString *)theURL delegate:(id<PopupMessageDelegate>) theDelegate;
-(id) initWithURL:(NSString *)theURL delegate:(id<PopupMessageDelegate>) theDelegate;
-(void) load;
-(void) unload;
-(void) popup;


@end

@protocol PopupMessageDelegate 

-(BOOL)popupMessageShouldDisplayMessage:(PopupMessage *)popup;

@end


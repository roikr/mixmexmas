//
//  PopupMessage.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageLoader.h"
#import "MessageParser.h"

@interface ButtonData : NSObject<NSCoding> {
    NSString *text;
    NSString *link;
    BOOL retry;
    BOOL pressed;
}
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *link;
@property BOOL retry;
@property BOOL pressed;

@end

@interface MessageData : NSObject<NSCoding> {
    NSString *title;
    NSString *message;
    NSMutableArray *buttons; 
    NSString *version;
    NSString *messageID;
    NSString *modified;
}

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *message;
@property (nonatomic,retain) NSMutableArray *buttons;
@property (nonatomic,retain) NSString *version;
@property (nonatomic,retain) NSString *messageID;
@property (nonatomic,retain) NSString *modified;

@end


@interface PopupMessage : NSObject<MessageLoaderDelegate,MessageParserDelegate> {
    MessageLoader *loader;
    MessageParser *parser;
    MessageData *data;
    NSURL *url;
}

@property (nonatomic,retain) MessageLoader *loader;
@property (nonatomic,retain) MessageParser *parser;
@property (nonatomic,retain) MessageData *data;
@property (nonatomic,retain) NSURL *url;

+(PopupMessage*) popupMessage:(NSURL *)theURL;

-(BOOL) shouldRetry;

@end

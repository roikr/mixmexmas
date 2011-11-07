//
//  MessageParser.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MessageParserDelegate;

@class MessageData;
@class ButtonData;

@interface MessageParser : NSObject<NSXMLParserDelegate> {
    id<MessageParserDelegate> delegate;
    
    NSMutableString *currentString;
    MessageData *messageData;
    ButtonData *currentButton;
    
}

@property (nonatomic, retain) id<MessageParserDelegate> delegate;

@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) MessageData *message;
@property (nonatomic, retain) ButtonData *currentButton;

+(MessageParser *)messageParser:(NSData*)xmlData delegate:(id<MessageParserDelegate>) theDelegate;


@end

@protocol MessageParserDelegate

-(void)messageParserDidFinish:(MessageParser *)parser;

@end
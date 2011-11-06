//
//  MessageParser.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLCacheConnection.h"

@protocol MessageParserDelegate;

@class URLCacheConnection;

@interface MessageParser : NSObject<NSXMLParserDelegate,URLCacheConnectionDelegate> {
    id<MessageParserDelegate> delegate;
    
    NSMutableString *currentString;
    UIAlertView *alertView;
    NSMutableArray *links;
    
    URLCacheConnection *connection;
   
    NSString *dataPath;
    NSString *filePath;
    NSDate *fileDate;
    
    NSError *error;
   
}

@property (nonatomic, retain) id<MessageParserDelegate> delegate;

@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) NSMutableArray *links;

@property (nonatomic, retain) URLCacheConnection *connection;


@property (nonatomic, copy) NSString *dataPath;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, retain) NSDate *fileDate;

+(MessageParser *)messageParser;
- (void)downloadAndParse:(NSURL *)theURL;


@end

@protocol MessageParserDelegate

-(void)MessageParserDelegateParsed:(MessageParser *)parser;

@end
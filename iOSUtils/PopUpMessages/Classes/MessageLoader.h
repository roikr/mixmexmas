//
//  MessageLoader.h
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MessageLoaderDelegate;

@class NSURLConnection;

@interface MessageLoader : NSObject {
    id<MessageLoaderDelegate> delegate;
    NSMutableData *xmlData;
    BOOL isModified;
    NSString *lastModified;
    NSURLConnection *connection;
}

@property (nonatomic, retain) id<MessageLoaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *xmlData;
@property BOOL isModified;
@property (nonatomic, retain) NSString *lastModified;
@property (nonatomic, retain) NSURLConnection *connection;

+(MessageLoader *)messageLoader:(NSURL *)theURL modified:(NSString *)modified delegate:(id<MessageLoaderDelegate>) theDelegate;
@end

@protocol MessageLoaderDelegate

-(void)messageLoaderDidFinished:(MessageLoader *)loader;
-(void)messageLoaderDidFailed:(MessageLoader *)loader;

@end
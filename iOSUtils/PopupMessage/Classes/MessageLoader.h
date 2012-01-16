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
    NSDate *lastModified;
    NSURLConnection *connection;
    
    NSInteger statusCode;
}

@property (nonatomic, retain) id<MessageLoaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic, retain) NSDate *lastModified;
@property (nonatomic, retain) NSURLConnection *connection;

@property NSInteger statusCode;

+(MessageLoader *)messageLoader:(NSURL *)theURL lastModified:(NSDate *)modified delegate:(id<MessageLoaderDelegate>) theDelegate;
@end

@protocol MessageLoaderDelegate

-(void)messageLoaderDidFinished:(MessageLoader *)loader;
-(void)messageLoaderDidFailed:(MessageLoader *)loader;

@end
//
//  YouTubeUploader.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	YOUTUBE_UPLOADER_STATE_IDLE,
	YOUTUBE_UPLOADER_STATE_INCORRECT_CREDENTIALS,
	YOUTUBE_UPLOADER_STATE_UPLOAD_REQUESTED,
	YOUTUBE_UPLOADER_STATE_UPLOADING,
	YOUTUBE_UPLOADER_STATE_UPLOAD_STOPPED,
	YOUTUBE_UPLOADER_STATE_UPLOAD_FINISHED
};

@class GDataServiceTicket;
@class RKUBackgroundTask;
@protocol YouTubeUploaderDelegate;

@interface YouTubeUploader : NSObject {

	GDataServiceTicket *mUploadTicket;
	NSMutableArray * delegates;
	
	NSString *videoTitle;
	NSString *videoDescription;
	NSString *videoPath;	
	
	NSString *username;
	NSString *password;
	
	float progress;
	
	NSURL *link;
	NSInteger _state;
	
	RKUBackgroundTask *task;
	
}

@property (nonatomic, retain) NSMutableArray * delegates;
@property (nonatomic,retain) NSString *videoTitle;
@property (nonatomic,retain) NSString *videoDescription;
@property (nonatomic,retain) NSString *videoPath;
@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *password;
@property (readonly) float progress;
@property (nonatomic,retain,readonly) NSURL *link;
@property (readonly) NSInteger state;

@property (nonatomic, retain) RKUBackgroundTask *task;


+ (YouTubeUploader *) youTubeUploader; 
-(void)addDelegate:(id<YouTubeUploaderDelegate>)delegate;
- (void) uploadVideoWithTitle:(NSString *)title withDescription:(NSString *)description andPath:(NSString *)path;
- (void) upload;
@end

@protocol YouTubeUploaderDelegate<NSObject>

@optional

- (void) youTubeUploaderStateChanged:(YouTubeUploader *)theUploader;
- (void) youTubeUploaderProgress:(float)progress;

@end


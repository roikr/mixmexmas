//
//  FacebookUploader.h
//  FacebookUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

enum {
	FACEBOOK_UPLOADER_STATE_IDLE,
	FACEBOOK_UPLOADER_STATE_DID_NOT_LOGIN,
	FACEBOOK_UPLOADER_STATE_DID_LOGIN,
	FACEBOOK_UPLOADER_STATE_UPLOADING,
	FACEBOOK_UPLOADER_STATE_UPLOAD_CANCELED,
	FACEBOOK_UPLOADER_STATE_UPLOAD_FAILED,
	FACEBOOK_UPLOADER_STATE_UPLOAD_FINISHED
};

@protocol FacebookUploaderDelegate;
@class RKUBackgroundTask;


@interface FacebookUploader : NSObject<FBRequestDelegate,FBSessionDelegate> { // FBDialogDelegate

	Facebook *facebook;
//	FBSession* session;
	
//	FBLoginDialog* loginDialog;
//	FBPermissionDialog* permissionDialog;
	
	NSMutableArray * delegates;
	
	NSString *videoTitle;
	NSString *videoDescription;
	NSString *videoPath;
	
	NSInteger _state;
	float progress;
	
	RKUBackgroundTask *task;
	
	//BOOL bDidEnterBackground; // ROIKR: using to avoid sending delegates when canceling upon entering background
}

@property (nonatomic, retain) NSMutableArray * delegates;
@property (nonatomic, retain) Facebook *facebook;
//@property (nonatomic,retain) FBSession *session;
@property (nonatomic,retain) NSString *videoTitle;
@property (nonatomic,retain) NSString *videoDescription;
@property (nonatomic,retain) NSString *videoPath;

@property (readonly) NSInteger state;
@property (readonly) float progress;
@property (nonatomic, retain) RKUBackgroundTask *task;

//@property (nonatomic, retain) FBLoginDialog* loginDialog;
//@property (nonatomic, retain) FBPermissionDialog* permissionDialog;

+ (FacebookUploader *) facebookUploader; 
-(void) addDelegate:(id<FacebookUploaderDelegate>)delegate; 
- (void) uploadVideoWithTitle:(NSString *)title withDescription:(NSString *)description andPath:(NSString *)path;
- (void) upload;
- (void)login;
- (void) logout;
- (BOOL) isConnected;
- (void)applicationDidEnterBackground;
@end

@protocol FacebookUploaderDelegate<NSObject>

@optional

- (void) facebookUploaderStateChanged:(FacebookUploader *)theUploader;
- (void) facebookUploaderProgress:(float)progress;

@end


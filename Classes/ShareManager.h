//
//  ShareManager.h
//  Milgrom
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookUploader.h"
#import "FacebookUploadViewController.h"
#import "YouTubeUploader.h"
#import "YouTubeUploadViewController.h"
#import "RenderManager.h"


enum {
	ACTION_UPLOAD_TO_FACEBOOK,
    ACTION_SEND_VIA_MAIL,
	ACTION_UPLOAD_TO_YOUTUBE,
	ACTION_ADD_TO_LIBRARY,
	ACTION_SEND_RINGTONE,
	ACTION_CANCEL,
    ACTION_SEND_YOUTUBE_LINK,
    ACTION_PUBLISH_YOUTUBE_LINK,
	ACTION_RENDER,
	ACTION_PLAY
};




@interface ShareManager : NSObject<FacebookUploaderDelegate,FacebookUploadViewControllerDelegate,YouTubeUploaderDelegate,YouTubeUploadViewControllerDelegate,MFMailComposeViewControllerDelegate,RenderManagerDelegate,UIAlertViewDelegate> {
	FacebookUploader *facebookUploader;
	YouTubeUploader *youTubeUploader;
	
	NSUInteger renderedAudioVersion;
	NSUInteger renderedVideoVersion;
	NSUInteger exportedRingtoneVersion;
	BOOL canSendMail;
	NSUInteger action;
	NSUInteger state;
	
	UIViewController *parentViewController;
	
	RenderManager *renderManager;
    
    NSString *youtubeLink;

}


@property (nonatomic,retain) FacebookUploader *facebookUploader;
@property (nonatomic,retain) YouTubeUploader *youTubeUploader;
@property (readonly) BOOL isUploading;

@property (readonly) BOOL audioRendered;
@property (readonly) BOOL videoRendered;
@property (readonly) BOOL ringtoneExported;

@property (nonatomic,retain) UIViewController *parentViewController;
@property (nonatomic,retain) RenderManager *renderManager;

@property (nonatomic,retain) NSString *youtubeLink;

+ (ShareManager*) shareManager;
- (NSString *)getCurrentActionName;

- (void)renderAudio;
-(void) performAction:(NSUInteger)theAction;
- (NSString *)getExoprtFileame;
- (NSString *)getDisplayName;
- (NSString *)getVideoPath;

- (void)resetVersions;
- (void)applicationDidEnterBackground;


    


@end

//
//  YouTubeUploadViewController.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTubeUploader.h"

@protocol YouTubeUploadViewControllerDelegate;

@interface YouTubeUploadViewController : UIViewController<YouTubeUploaderDelegate> {
	YouTubeUploader *uploader;
	
	UITextField *username;
	UITextField *password;
	UITextField *titleField;
	UITextView *description;
	UIButton *keyboardButton;
	
	
	NSString *videoName;
	NSString *path;
	
	UIView *uploadView;
	
	UIScrollView *srcollView;
		
	NSString *additionalText;
	
	UIView *processView;
	
	id<YouTubeUploadViewControllerDelegate> delegate;
	
	BOOL bDelayedUpload;
	
}

@property (nonatomic,retain) YouTubeUploader *uploader;

@property (nonatomic,retain) IBOutlet UITextField *username;
@property (nonatomic,retain) IBOutlet UITextField *password;
@property (nonatomic,retain) IBOutlet UITextField *titleField;
@property (nonatomic,retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UIButton *keyboardButton;

@property (nonatomic,retain) IBOutlet UIView *processView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;

@property (nonatomic,retain) NSString* additionalText;

@property BOOL bDelayedUpload;

-(void)setDelegate:(id<YouTubeUploadViewControllerDelegate>)theDelegate;
- (void) upload:(id)sender;
- (void) cancel:(id)sender;
- (void) closeTextView:(id)sender;
@end

@protocol YouTubeUploadViewControllerDelegate<NSObject>

- (void) YouTubeUploadViewControllerUpload:(YouTubeUploadViewController *)controller;
- (void) YouTubeUploadViewControllerCancel:(YouTubeUploadViewController *)controller;

@end

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

@interface YouTubeUploadViewController : UIViewController<YouTubeUploaderDelegate,UIScrollViewDelegate> {
	YouTubeUploader *uploader;
	
	UITextField *username;
	UITextField *password;
	UITextField *titleField;
	UITextView *description;
   	
	NSString *videoName;
	NSString *path;
	
	UIView *uploadView;
	
	UIScrollView *srcollView;
		
	NSString *additionalText;
	
	UIView *processView;
	
	id<YouTubeUploadViewControllerDelegate> delegate;
	
	BOOL bDelayedUpload;
    
    UIView *activeView;
    BOOL _isKeyboardVisible;
    
    UILabel *titleLabel;
    UILabel *descLabel;
    UILabel *usernameLabel;
    UILabel *passwordLabel;
    UIButton *uploadButton;
    UIButton *cancelButton;
    
}

@property (nonatomic,retain) YouTubeUploader *uploader;

@property (nonatomic,retain) IBOutlet UITextField *username;
@property (nonatomic,retain) IBOutlet UITextField *password;
@property (nonatomic,retain) IBOutlet UITextField *titleField;
@property (nonatomic,retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic,retain) IBOutlet UIView *processView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;

@property (nonatomic,retain) NSString* additionalText;

@property BOOL bDelayedUpload;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descLabel;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

-(void)setDelegate:(id<YouTubeUploadViewControllerDelegate>)theDelegate;
- (IBAction) upload:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) closeTextView:(id)sender;
@end

@protocol YouTubeUploadViewControllerDelegate<NSObject>

- (void) YouTubeUploadViewControllerUpload:(YouTubeUploadViewController *)controller;
- (void) YouTubeUploadViewControllerCancel:(YouTubeUploadViewController *)controller;

@end

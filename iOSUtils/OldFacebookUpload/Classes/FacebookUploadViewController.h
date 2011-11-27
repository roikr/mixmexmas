//
//  FacebookUploadViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FacebookUploader.h"

@protocol FacebookUploadViewControllerDelegate;

@interface FacebookUploadViewController : UIViewController<FacebookUploaderDelegate> {
	FacebookUploader *uploader;
	
	UITextField *titleField;
	UITextView *descriptionView;
	
	NSString *videoPath;
	
	UIScrollView *srcollView;
	
	NSString *additionalText;
	
	id<FacebookUploadViewControllerDelegate> delegate;
	
	BOOL bDelayedUpload;
    
    UIView *activeView;
    BOOL _isKeyboardVisible;
    
    UILabel *titleLabel;
    UILabel *messageLabel;
    UIButton *loginButton;
    UIButton *cancelButton;
    UIButton *postButton;
    UIButton *logoutButton;
}

@property (nonatomic, retain) FacebookUploader *uploader;
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) UIView *activeView;
//@property (nonatomic, retain) IBOutlet UIView *scrollView;

@property BOOL bDelayedUpload;

@property (nonatomic,retain ) IBOutlet NSString *videoTitle;
@property (nonatomic,retain) IBOutlet NSString* videoPath;
@property (nonatomic,retain) IBOutlet NSString* additionalText;
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) IBOutlet UILabel *messageLabel;
@property (nonatomic,retain) IBOutlet UIButton *loginButton;
@property (nonatomic,retain) IBOutlet UIButton *cancelButton;
@property (nonatomic,retain) IBOutlet UIButton *postButton;
@property (nonatomic,retain) IBOutlet UIButton *logoutButton;


-(void)setDelegate:(id<FacebookUploadViewControllerDelegate>)theDelegate;
- (IBAction) upload:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) login:(id)sender;
- (IBAction) closeTextView:(id)sender;
- (IBAction) logout:(id)sender;



@end

@protocol FacebookUploadViewControllerDelegate<NSObject>

- (void) FacebookUploadViewControllerUpload:(FacebookUploadViewController *)controller;
- (void) FacebookUploadViewControllerCancel:(FacebookUploadViewController *)controller;

@end
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
	UIButton *keyboardButton;
	
	NSString *videoPath;
	
	UIScrollView *srcollView;
	
	NSString *additionalText;
	
	id<FacebookUploadViewControllerDelegate> delegate;
	
	BOOL bDelayedUpload;
}

@property (nonatomic, retain) FacebookUploader *uploader;
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) UIView *activeView;
@property (nonatomic, retain) IBOutlet UIButton *keyboardButton;
//@property (nonatomic, retain) IBOutlet UIView *scrollView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;
@property (nonatomic,retain) NSString* additionalText;

@property BOOL bDelayedUpload;

-(void)setDelegate:(id<FacebookUploadViewControllerDelegate>)theDelegate;
- (void) upload:(id)sender;
- (void) cancel:(id)sender;
- (void) login:(id)sender;
- (void) closeTextView:(id)sender;
- (void) logout:(id)sender;
- (void) touchDown:(id)sender;


@end

@protocol FacebookUploadViewControllerDelegate<NSObject>

- (void) FacebookUploadViewControllerUpload:(FacebookUploadViewController *)controller;
- (void) FacebookUploadViewControllerCancel:(FacebookUploadViewController *)controller;

@end
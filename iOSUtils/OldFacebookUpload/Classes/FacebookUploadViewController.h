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
}

@property (nonatomic, retain) FacebookUploader *uploader;
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) UIView *activeView;
//@property (nonatomic, retain) IBOutlet UIView *scrollView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;
@property (nonatomic,retain) NSString* additionalText;

@property BOOL bDelayedUpload;

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
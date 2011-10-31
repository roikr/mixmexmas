//
//  MainViewController.h
//  SingingCard
//
//  Created by Roee Kremer on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


//@class CustomFontTextField;
//@class CustomImageView;
@class RenderProgressView;

@interface MainViewController : UIViewController
{
       
	UIView *buttonsView;
	
	
	UIView *liveView;
	UITextView *liveTextView;
	UIView *recordView;
	UITextView *recordTextView;
	UIView *playView;
	UIButton *playButton;

	
	RenderProgressView *renderProgressView;
	
//	CustomImageView *shareProgressView;

	UIButton *cameraToggleButton;
	
}




@property (nonatomic, retain) IBOutlet UIView *liveView;
@property (nonatomic, retain) IBOutlet UITextView *liveTextView;
@property (nonatomic, retain) IBOutlet UIView *recordView;
@property (nonatomic, retain) IBOutlet UITextView *recordTextView;
@property (nonatomic, retain) IBOutlet UIView *playView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet RenderProgressView *renderProgressView;


//@property (nonatomic,retain ) IBOutlet CustomImageView *shareProgressView;

@property (nonatomic,retain) IBOutlet UIButton *cameraToggleButton;


- (IBAction) more:(id)sender;
- (IBAction) live:(id)sender;
- (IBAction) record:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) preview:(id)sender;
- (IBAction) play:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) share:(id)sender;

- (IBAction)cameraToggle:(id)sender;

- (void)updateViews;
- (void) setShareProgress:(float) progress;


@end

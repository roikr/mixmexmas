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
	UILabel *liveViewLabel;
	UIView *recordView;
    UIImageView *imageView;
	UILabel *recordViewLabel;
	UIView *playView;
	UIButton *playButton;
    
   

	
	RenderProgressView *renderProgressView;
	
//	CustomImageView *shareProgressView;

	UIButton *cameraToggleButton;
    
    UIButton *recordButton1;
    UIButton *recordButton2;
    UIButton *startOverButton;
    UIButton *shareButton;
    UIButton *switchButton1;
    UIButton *switchButton2;
	
}




@property (nonatomic, retain) IBOutlet UIView *liveView;
@property (nonatomic, retain) IBOutlet UILabel *liveViewLabel;
@property (nonatomic, retain) IBOutlet UIView *recordView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *recordViewLabel;
@property (nonatomic, retain) IBOutlet UIView *playView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;

@property (nonatomic, retain) IBOutlet RenderProgressView *renderProgressView;


//@property (nonatomic,retain ) IBOutlet CustomImageView *shareProgressView;

@property (nonatomic,retain) IBOutlet UIButton *cameraToggleButton;

@property (nonatomic,retain) IBOutlet UIButton *recordButton1;
@property (nonatomic,retain) IBOutlet UIButton *recordButton2;
@property (nonatomic,retain) IBOutlet UIButton *startOverButton;
@property (nonatomic,retain) IBOutlet UIButton *shareButton;
@property (nonatomic,retain) IBOutlet UIButton *switchButton1;
@property (nonatomic,retain) IBOutlet UIButton *switchButton2;





- (IBAction) more:(id)sender;
- (IBAction) live:(id)sender;
- (IBAction) record:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) preview:(id)sender;
- (IBAction) play:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) share:(id)sender;

- (IBAction)cameraToggle:(id)sender;

- (IBAction)info:(id)sender;

- (void)updateViews;
- (void) setShareProgress:(float) progress;


@end

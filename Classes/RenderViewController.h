//
//  RenderViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomImageView;
@class ExportManager;
@class OpenGLTOMovie;
@class RenderView;

@protocol RenderViewControllerDelegate;

@interface RenderViewController : UIViewController {
	id<RenderViewControllerDelegate> delegate;
	
	RenderView *renderView;
	UILabel *renderLabel;
	UIButton *renderCancelButton;
	UIImageView *renderCameraIcon;
	
	ExportManager *exportManager;
	OpenGLTOMovie *renderManager;
	
	UIProgressView *renderProgressView;
	
	
	UITextView *renderTextView;
}

@property (nonatomic, retain) IBOutlet RenderView *renderView;
@property (nonatomic, retain) IBOutlet UILabel *renderLabel;
@property (nonatomic, retain) IBOutlet UIButton *renderCancelButton;
@property (nonatomic, retain) IBOutlet UIImageView *renderCameraIcon;
@property (nonatomic,retain ) IBOutlet UIProgressView *renderProgressView;

@property (nonatomic, retain) ExportManager *exportManager;
@property (nonatomic, retain) OpenGLTOMovie *renderManager;

-(void)setDelegate:(id<RenderViewControllerDelegate>)theDelegate;
- (void)renderAudio;
- (void)renderVideo;
- (void)exportRingtone;
- (void)cancelRendering:(id)sender;
- (void)applicationDidEnterBackground;

@end

@protocol RenderViewControllerDelegate<NSObject> 

- (void) RenderViewControllerDelegateCanceled:(RenderViewController *)controller;
- (void) RenderViewControllerDelegateAudioRendered:(RenderViewController *)controller;
- (void) RenderViewControllerDelegateVideoRendered:(RenderViewController *)controller;
- (void) RenderViewControllerDelegateRingtoneExported:(RenderViewController *)controller;


@end


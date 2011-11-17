//
//  MainViewController.m
//  SingingCard
//
//  Created by Roee Kremer on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h> // only for camera count

#import "MainViewController.h"
#import "ShareViewController.h"
#import "InfoViewController.h"
#import "EAGLView.h"
#import "SingingCardAppDelegate.h"

#include "Constants.h"
#include "testApp.h"

#import "EAGLView.h"
#import "glu.h"
#import "ShareManager.h"

#import "RKMacros.h"

#import "ShareManager.h"
#import "RenderProgressView.h"
#import "CustomImageView.h"

#ifdef _FLURRY
#import "FlurryAnalytics.h"
#endif

@interface MainViewController ()
- (NSUInteger) cameraCount;
- (void) fadeOutRecordButton;
- (void) fadeInRecordButton;
@end

@implementation MainViewController

@synthesize liveView;
@synthesize liveTextView;
@synthesize recordView;
@synthesize imageView;
@synthesize recordTextView;
@synthesize playView;
@synthesize playButton;
@synthesize renderProgressView;


//@synthesize shareProgressView;




@synthesize cameraToggleButton;

- (void)viewDidLoad	// need to be called after the EAGL awaked from nib
//- (void)awakeFromNib
{
	[super viewDidLoad];
	ShareManager *shareManager = [(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) {
        self.renderProgressView.progressView.image =  [UIImage imageNamed:@"PREPARING_CARD_BAR@2x.png"];
    } else {
        self.renderProgressView.progressView.image =  [UIImage imageNamed:@"PREPARING_CARD_BAR.png"];
    }

	
	[shareManager.renderManager setRenderProgressView:self.renderProgressView];
	[self.renderProgressView.cancelButton addTarget:shareManager.renderManager action:@selector(cancelRendering:) forControlEvents:UIControlEventTouchUpInside];
	self.cameraToggleButton.hidden = [self cameraCount] <= 1;
	
	[self.liveTextView setFont:[[self.liveTextView font] fontWithSize:22]];
	[self.recordTextView setFont:[[self.recordTextView font] fontWithSize:22]];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (testApp *)OFSAptr {
	return [(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] OFSAptr];
}

- (void)updateViews {
	
//	if (self.navigationController.topViewController != self) {
//		return;
//	}
	

	liveView.hidden = YES;
	recordView.hidden = YES;
	playView.hidden = YES;
	playButton.selected = NO;
	renderProgressView.hidden = YES;
	renderProgressView.cancelButton.hidden = YES;
	
	
	
	switch (self.OFSAptr->getSongState()) {
		case SONG_IDLE:
		case SONG_PLAY: {
			buttonsView.hidden = NO;
			switch (self.OFSAptr->getState()) {
				case STATE_LIVE:
					liveView.hidden = NO;

					break;
				case STATE_RECORD:
					recordView.hidden = NO;
                     [self fadeOutRecordButton];
					
					break;
				case STATE_PLAY:
					playView.hidden = NO;
					playButton.selected = self.OFSAptr->getSongState() == SONG_PLAY;
				default:
					break;
			}
			
		}	break;
		case SONG_RENDER_VIDEO:
		case SONG_EXPORT_RINGTONE:
			renderProgressView.cancelButton.hidden = NO;
		case SONG_RENDER_AUDIO:
		case SONG_RENDER_AUDIO_FINISHED:
		case SONG_CANCEL_RENDER_AUDIO:
			renderProgressView.hidden = NO;
		default:
			break;
	}
}

- (IBAction) more:(id)sender {
	self.OFSAptr->more();
}

- (IBAction) live:(id)sender {
	self.OFSAptr->live();
}

- (IBAction) record:(id)sender {
	self.OFSAptr->record();
#ifdef _FLURRY
    [FlurryAnalytics logEvent:@"RECORD" withParameters:[NSDictionary dictionaryWithObject:[(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] getCurrentCardTag] forKey:@"CARD"]];
#endif
}

- (void) fadeOutRecordButton {
	if (self.OFSAptr->getState() == STATE_RECORD) {
		[UIView animateWithDuration:0.1 delay:0.5 
							options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
						 animations:^{imageView.alpha = 0.0;} 
						 completion:^(BOOL finished){ [self fadeInRecordButton]; }];
		
		
	} 
}

- (void) fadeInRecordButton {
	if (self.OFSAptr->getState() == STATE_RECORD) {
		[UIView animateWithDuration:0.1 delay:0.5 
							options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
						 animations:^{imageView.alpha = 1.0;} 
						 completion:^(BOOL finished){ [self fadeOutRecordButton]; }];
		
		
	} 
}

- (IBAction) preview:(id)sender {
	self.OFSAptr->preview();
}

- (IBAction) play:(id)sender {
		self.OFSAptr->setSongState(self.OFSAptr->getSongState() == SONG_PLAY ? SONG_IDLE : SONG_PLAY);
}

- (IBAction) stop:(id)sender {
	self.OFSAptr->setSongState(SONG_IDLE);
}

- (IBAction) share:(id)sender {
	
	ShareManager *shareManager = [(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
	
	if ([shareManager isUploading]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"still uploading title",@"Sharing") message:NSLocalizedString(@"still uploading body",@"Video upload in progress") delegate:nil  cancelButtonTitle:NSLocalizedString(@"ok button","OK")  otherButtonTitles: nil];
		[alert show];
		[alert release];
	} else {
		
		//[[(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager] prepare];
		[shareManager renderAudio];
	}
	// BUG FIX: this is very important: don't present from milgromViewController as it will result in crash when returning to BandView after share
	
}

- (IBAction)cameraToggle:(id)sender
{
    self.OFSAptr->cameraToggle();
}

- (IBAction)info:(id)sender {
    SingingCardAppDelegate *appDelegate = (SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.infoViewController setUrl:@"http://www.lofipeople.com/gogos/info/info"];
    [appDelegate.mainViewController presentModalViewController:appDelegate.infoViewController animated:YES];
    
#ifdef _FLURRY
    [FlurryAnalytics logEvent:@"INFO"];
#endif
}

#pragma mark Render && Share

- (void) setShareProgress:(float) progress {
//	[shareProgressView setRect:CGRectMake(0, 1.0-progress, 1.0f,progress)];
}

- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

@end

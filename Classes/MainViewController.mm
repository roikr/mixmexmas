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
#import "SingingCardKeys.h"

#ifdef _FLURRY
#import "FlurryAnalytics.h"
#endif

#ifdef IN_APP_STORE
#import "SingleProductStore.h"
#endif

@interface MainViewController ()
- (NSUInteger) cameraCount;
- (void) fadeOutRecordButton;
- (void) fadeInRecordButton;
@end

@implementation MainViewController

@synthesize liveView;
@synthesize liveViewLabel;
@synthesize recordView;
@synthesize imageView;
@synthesize recordViewLabel;
@synthesize playView;
@synthesize playButton;
@synthesize renderProgressView;

@synthesize  recordButton1,recordButton2,startOverButton,shareButton,switchButton1,switchButton2;


//@synthesize shareProgressView;




@synthesize cameraToggleButton;

- (void)viewDidLoad	// need to be called after the EAGL awaked from nib
//- (void)awakeFromNib
{
	[super viewDidLoad];
	ShareManager *shareManager = [(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) {
        self.renderProgressView.progressView.image =  [UIImage imageNamed:@"LOADING_BAR@2x.png"];
    } else {
        self.renderProgressView.progressView.image =  [UIImage imageNamed:@"LOADING_BAR.png"];
    }

#ifdef LIVE_TEXT
    [recordButton1 setTitle:NSLocalizedString(@"UI Record",@"Record") forState:UIControlStateNormal];
    [recordButton2 setTitle:NSLocalizedString(@"UI Record",@"Record") forState:UIControlStateNormal];
    [startOverButton setTitle:NSLocalizedString(@"UI Start over",@"Start over") forState:UIControlStateNormal];
    [playButton setTitle:NSLocalizedString(@"UI Play",@"Play") forState:UIControlStateNormal];
    [playButton setTitle:NSLocalizedString(@"UI Stop",@"Stop") forState:UIControlStateSelected];
    [shareButton setTitle:NSLocalizedString(@"UI Share",@"Share") forState:UIControlStateNormal];
    [switchButton1 setTitle:NSLocalizedString(@"UI Switch card",@"Switch card") forState:UIControlStateNormal];
    [switchButton2 setTitle:NSLocalizedString(@"UI Switch card",@"Switch card") forState:UIControlStateNormal];
    [renderProgressView.cancelButton setTitle:NSLocalizedString(@"render cancel",@"Cancel";) forState:UIControlStateNormal];
    [liveViewLabel setText:NSLocalizedString(@"UI Record message",@"Pose your face in place, hit record and make a sound")];
    [recordViewLabel setText:NSLocalizedString(@"UI Make a sound",@"C'mon, make a sound!")];

    recordButton1.titleLabel.adjustsFontSizeToFitWidth = YES;
    recordButton2.titleLabel.adjustsFontSizeToFitWidth = YES;
    startOverButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    playButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    shareButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    switchButton1.titleLabel.adjustsFontSizeToFitWidth = YES;
    switchButton2.titleLabel.adjustsFontSizeToFitWidth = YES;
    renderProgressView.cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    startOverButton.titleLabel.textAlignment = UITextAlignmentCenter;
    switchButton1.titleLabel.textAlignment = UITextAlignmentCenter;
    switchButton2.titleLabel.textAlignment = UITextAlignmentCenter;
    
    startOverButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    shareButton.titleLabel.numberOfLines = 1;
#endif
	
	[shareManager.renderManager setRenderProgressView:self.renderProgressView];
	[self.renderProgressView.cancelButton addTarget:shareManager.renderManager action:@selector(cancelRendering:) forControlEvents:UIControlEventTouchUpInside];
	self.cameraToggleButton.hidden = [self cameraCount] <= 1;
	
//	[self.liveViewLabel setFont:[[self.liveViewLabel font] fontWithSize:22]];
//	[self.recordViewLabel setFont:[[self.recordViewLabel font] fontWithSize:22]];
	
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

#ifdef IN_APP_STORE
    SingleProductStore *store = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).store;
    
    shareButton.hidden = store.state == STORE_STATE_NONE;
    shareButton.selected = store.state == STORE_STATE_PRODUCT_EXIST;
#endif
	
	
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
        case SONG_RENDER_AUDIO:
			renderProgressView.hidden = NO;
            renderProgressView.cancelButton.hidden = NO;
            renderProgressView.cancelButton.userInteractionEnabled = YES;
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
	
#ifdef IN_APP_STORE
    SingleProductStore *store = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).store;
    
    if (store.state == STORE_STATE_PRODUCT_EXIST) {
        if (![store canMakePayments]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No pay no game !"  message:@"Ask you mom for the credit card number"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
           [store buy];
        }
        
        return;
    }
#endif
    
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
    [appDelegate.infoViewController setUrl:kInfoURL];
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

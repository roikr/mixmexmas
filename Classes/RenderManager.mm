//
//  RenderManager.mm
//  SingingCard
//
//  Created by Roee Kremer on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RenderManager.h"
#import "SingingCardAppDelegate.h"
#include "testApp.h"
#include "Constants.h"
#import "OpenGLTOMovie.h"
#import "glu.h"
#import "ExportManager.h"
#import "RenderProgressView.h"
#include "ofxiVideoGrabber.h"


#import "EAGLView.h"
#import "ShareManager.h"
#import "RKMacros.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif


@interface RenderManager() 

- (void)updateRenderProgress;
- (void)updateExportProgress:(ExportManager*)manager;
- (void) setRenderProgress:(float) progress;

@end


@implementation RenderManager

@synthesize exportManager;
@synthesize renderer;
@synthesize renderProgressView;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */








- (void)dealloc {
	// TODO: clean here
    [super dealloc];
}

-(void)setDelegate:(id<RenderManagerDelegate>)theDelegate {
	delegate = theDelegate;
}



/* used to be in mainViewController updateViews
 int songState =OFSAptr->getSongState();
 if (songState == SONG_RENDER_VIDEO || songState == SONG_RENDER_VIDEO_FINISHED || songState == SONG_RENDER_AUDIO || songState == SONG_CANCEL_RENDER_AUDIO || songState == SONG_RENDER_AUDIO_FINISHED || exportManager) {
 if (![self.view.subviews containsObject:renderView]) {
 [self.view addSubview:renderView];
 }
 
 
 renderView.slideView.hidden =renderCancelButton.hidden = renderCameraIcon.hidden = songState!=SONG_RENDER_VIDEO;
 
 return;
 } else if ([self.view.subviews containsObject:renderView]) {
 [renderView removeFromSuperview];
 } 
 */

- (void) setRenderProgress:(float) progress {
	[delegate renderManagerProgress:progress];
	[self.renderProgressView setRenderProgress:progress];
}

- (void)updateRenderProgress
{
	
	testApp *OFSAptr = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	if (OFSAptr->getSongState()==SONG_RENDER_AUDIO || OFSAptr->getSongState()==SONG_RENDER_VIDEO) {
		float progress = OFSAptr->getRenderProgress();
		[self setRenderProgress:progress];
		//NSLog(@"rendering, progrss: %2.2f",progress);
		
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	}
}

- (void)renderAudio {
	
	
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderAudioQueue", NULL);
	
	testApp *OFSAptr = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	OFSAptr->grabber.stopCamera();
	OFSAptr->soundStreamStop();
	
	dispatch_async(myCustomQueue, ^{
		
		OFSAptr->renderAudio();
		
		
		dispatch_async(dispatch_get_main_queue(), ^{
			OFSAptr->setSongState(SONG_IDLE); // roikr: is this fixed the stubborn 
			OFSAptr->soundStreamStart();
			OFSAptr->grabber.startCamera();
			[delegate renderManagerAudioRendered:self];
		});
		
		
	});
	
	dispatch_release(myCustomQueue);
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	
#ifdef _FLURRY
	[FlurryAPI logEvent:@"RENDER_AUDIO" timed:YES];
#endif
	
}







- (void)renderVideo {
		
	[self setRenderProgress:0.0f];
	
	SingingCardAppDelegate * appDelegate = (SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate];
	ShareManager *shareManager = [appDelegate shareManager];
	
	testApp *OFSAptr = appDelegate.OFSAptr;
	
	self.renderer = [OpenGLTOMovie renderManager];
	
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderQueue", NULL);
	
	OFSAptr->grabber.stopCamera();
	OFSAptr->soundStreamStop();
	
	OFSAptr->setSongState(SONG_RENDER_VIDEO);
	
	dispatch_async(myCustomQueue, ^{
		
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		[renderer writeToVideoURL:[NSURL fileURLWithPath:[[shareManager getVideoPath]  stringByAppendingPathExtension:@"mov"]] withAudioURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.caf"]] 
		 
		 
						   withContext:appDelegate.eAGLView.context
							  withSize:CGSizeMake(480, 320) 
			   withAudioAverageBitRate:[NSNumber numberWithInt: 192000 ]
			   withVideoAverageBitRate:[NSNumber numberWithDouble:VIDEO_BITRATE*1000.0] // appDelegate.videoBitrate
		 
			 withInitializationHandler:^ {
				 glMatrixMode (GL_PROJECTION);
				 glLoadIdentity ();
				 gluOrtho2D (0, 480, 0, 320);
				 
			 }
		 
						 withDrawFrame:^(int frameNum) {
							 //NSLog(@"rendering frame: %i, progress: %2.2f",frameNum,OFSAptr->getRenderProgress());
							 OFSAptr->seekFrame(frameNum+1); // roikr: for synching
							 
							 glMatrixMode(GL_MODELVIEW);
							 glLoadIdentity();
							 
							 OFSAptr->renderVideo();
							 
							 
						 }
		 
					   withIsRendering:^ {
						   
						   return (int)(OFSAptr->getRenderProgress()<1.0f);
					   }
		 
				 withCompletionHandler:^ {
					 NSLog(@"write completed");
					 OFSAptr->setSongState(SONG_IDLE);
					 OFSAptr->soundStreamStart();
					 OFSAptr->grabber.startCamera();

					 [delegate renderManagerVideoRendered:self];
					 
					 self.renderer = nil;
					 
#ifdef _FLURRY
					 [FlurryAPI endTimedEvent:@"RENDER_VIDEO" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"COMPLETED",@"STATUS", nil]];
#endif
					 
				 }
		 
				withCancelationHandler:^ {
					NSLog(@"videoRender canceled");
					OFSAptr->setSongState(SONG_IDLE);
					 OFSAptr->soundStreamStart();
					 OFSAptr->grabber.startCamera();
					[delegate renderManagerRenderCanceled:self];
					self.renderer = nil;
#ifdef _FLURRY
					[FlurryAPI endTimedEvent:@"RENDER_VIDEO" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"CANCELED",@"STATUS", nil]];
#endif
				}
		 
				   withAbortionHandler:^ {
					   NSLog(@"videoRender aborted");
					   OFSAptr->setSongState(SONG_IDLE);
					   self.renderer = nil;  
#ifdef _FLURRY
					   [FlurryAPI endTimedEvent:@"RENDER_VIDEO" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"ABORTED",@"STATUS", nil]];
#endif
				   }
		 
		 ];
	});
	
	
	dispatch_release(myCustomQueue);
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	
#ifdef _FLURRY
	[FlurryAPI logEvent:@"RENDER_VIDEO" timed:YES];
#endif
	
	
}


- (void)exportRingtone {
	[self setRenderProgress:0.0f];
	
	
	ShareManager *shareManager = [(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
	testApp *OFSAptr = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	OFSAptr->soundStreamStop();
	OFSAptr->setSongState(SONG_EXPORT_RINGTONE);
	
	//ShareManager *shareManager = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	self.exportManager = [ExportManager  exportAudio:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.caf"]]
						  
											   toURL:[NSURL fileURLWithPath:[[shareManager getVideoPath] stringByAppendingPathExtension:@"m4r"]]
						  
						  
							   withCompletionHandler:^ {
								   NSLog(@"export completed");
								   
								   OFSAptr->setSongState(SONG_IDLE);
								   OFSAptr->soundStreamStart();
								   
								   if ([exportManager didExportComplete]) {
									   [delegate renderManagerRingtoneExported:self];
									   
								   }
								   
								   self.exportManager = nil;
								   //[self updateViews]; // TODO: update aqui
								   
							   }];
	
	NSArray *modes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil];
	[self performSelector:@selector(updateExportProgress:) withObject:exportManager afterDelay:0.5 inModes:modes];
	
	
}




- (void)updateExportProgress:(ExportManager*)manager
{
	
	if (!manager.didFinish) {
		//MilgromLog(@"export audio, progrss: %2.2f",manager.progress);
		[self setRenderProgress:manager.progress];
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateExportProgress:) withObject:manager afterDelay:0.5 inModes:modes];
	}
}


- (void)cancelRendering:(id)sender {
	
	SingingCardAppDelegate * appDelegate = (SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate];
	testApp *OFSAptr = appDelegate.OFSAptr;
	
	switch (OFSAptr->getSongState()) {
		case SONG_RENDER_VIDEO:  
			[self.renderer cancelRender];
			break;
		case SONG_RENDER_AUDIO:
			OFSAptr->setSongState(SONG_CANCEL_RENDER_AUDIO); // TODO: need to be checked
			break;
		default:
			break;
	}
	
	if (exportManager) {
		[exportManager cancelExport];
		self.exportManager = nil;
		[delegate renderManagerRenderCanceled:self];
	}
	
	
	
	
	
}



- (void)applicationDidEnterBackground {
	if (renderer) {
		[self.renderer abortRender];
	}
	
	if (exportManager) {
		[self.exportManager cancelExport];
		self.exportManager = nil;
	}
	
}


@end

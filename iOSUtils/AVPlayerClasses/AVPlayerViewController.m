//
//  AVPlayerViewController.m
//  SingingCard
//
//  Created by Roee Kremer on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerDemoPlaybackView.h"

@interface AVPlayerViewController()
-(void)close;
@end


@implementation AVPlayerViewController

@synthesize player;
@synthesize delegate;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	self.player = nil;
    [super dealloc];
}


//static NSString* const AVPlayerViewControllerRateObservationContext = @"AVPlayerViewControllerRateObservationContext";
static NSString* const AVPlayerViewControllerReadyForDisplayObservationContext = @"AVPlayerViewControllerReadyForDisplayObservationContext";

-(void)loadAssetFromURL:(NSURL *)fileURL {
	NSLog(@"AVPlayerViewController::loadAssetFromURL");

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
	    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:
     ^{
		 NSError *error = nil;
		 AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
         NSLog(@"AVPlayerViewController - loadValuesAsynchronouslyForKeys - completionHandler");
		 if (status == AVKeyValueStatusLoaded) {
             
             
             NSLog(@"completionHandler: AVKeyValueStatusLoaded");
             
             dispatch_async(dispatch_get_main_queue(),
            ^{
                AVPlayerLayer *layer = (AVPlayerLayer *)[(AVPlayerDemoPlaybackView *)self.view layer];
                [layer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:AVPlayerViewControllerReadyForDisplayObservationContext];
                
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
                
                self.player = [AVPlayer playerWithPlayerItem:playerItem];
                //			 [self.player addObserver:self forKeyPath:@"rate" options:0 context:AVPlayerViewControllerRateObservationContext];
                
                [(AVPlayerDemoPlaybackView *)self.view setPlayer:self.player];
                [self.player play];
            });
			 
			 
		 }
		 else {
			 // Deal with the error appropriately.
			 NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
		 }
     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    NSLog(@"observeValueForKeyPath: %@", keyPath);
	
    if (context == AVPlayerViewControllerReadyForDisplayObservationContext) {
		dispatch_async(dispatch_get_main_queue(),
		   ^{
				[delegate AVPlayerLayerIsReadyForDisplay:self];
		   });
		
//    } else if (context == AVPlayerViewControllerRateObservationContext)
//	{
//		dispatch_async(dispatch_get_main_queue(),
//					   ^{
//						   if (player.rate == 0.0) {
//							   [self close];
//						   }
//					   });
	} else {	
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
  
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
	dispatch_async(dispatch_get_main_queue(),
	   ^{
		   [self close];
	   });
	
   
}

-(IBAction)skip:(id)sender {
	[self.player pause];
	self.view.userInteractionEnabled = NO;
	[self close];
}

-(void)close {
	NSLog(@"AVPlayerViewController - close");
	AVPlayerLayer *layer = (AVPlayerLayer *)[(AVPlayerDemoPlaybackView *)self.view layer];
	[layer removeObserver:self forKeyPath:@"readyForDisplay"];
//	[player removeObserver:self forKeyPath:@"rate"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self dismissModalViewControllerAnimated:YES];
	[delegate AVPlayerViewControllerDone:self];
}


@end

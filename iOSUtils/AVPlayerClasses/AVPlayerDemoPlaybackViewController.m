/*

File: AVPlayerDemoPlaybackViewController.h

Abstract: UIViewController managing a playback view, thumbnail view, and associated playback UI.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2010 Apple Inc. All Rights Reserved.

*/


#import "AVPlayerDemoPlaybackViewController.h"

#import "AVPlayerDemoPlaybackView.h"


#import <AVFoundation/AVFoundation.h>

@interface AVPlayerDemoPlaybackViewController()
- (void)syncButtons;
- (void)syncScrubber;
@end

static NSString* const AVPlayerDemoPlaybackViewControllerRateObservationContext = @"AVPlayerDemoPlaybackViewControllerRateObservationContext";
static NSString* const AVPlayerDemoPlaybackViewControllerDurationObservationContext = @"AVPlayerDemoPlaybackViewControllerDurationObservationContext";

@implementation AVPlayerDemoPlaybackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		mPlayer = [[AVPlayer allocWithZone:[self zone]] init];
		[mPlayer addObserver:self forKeyPath:@"rate" options:0 context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
		[mPlayer addObserver:self forKeyPath:@"currentItem.asset.duration" options:0 context:AVPlayerDemoPlaybackViewControllerDurationObservationContext];
		
		[self setWantsFullScreenLayout:YES];
	}
	
	return self;
}

- (id)init
{
	return [self initWithNibName:@"AVPlayerDemoPlaybackView" bundle:nil];
}

- (void)dealloc
{
	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
		[mTimeObserver release];
	}
	[mPlayer removeObserver:self forKeyPath:@"rate"];
	[mPlayer removeObserver:self forKeyPath:@"currentItem.asset.duration"];
	[mPlayer pause];
	[mPlayer release];
	[mURL release];
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (NSURL*)URL
{
	return mURL;
}

- (void)setURL:(NSURL*) URL
{
	if (mURL != URL)
	{
		[mURL release];
		mURL = [URL copyWithZone:[self zone]];
		
		[mPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:URL]];
	}
}

- (AVPlayer*)player
{
	return mPlayer;
}

- (void)viewDidLoad
{
	UIView* view  = [self view];
	[super viewDidLoad];
	
	[mPlaybackView setPlayer:mPlayer];
		
	UISwipeGestureRecognizer* swipeUpRecognizer = [[UISwipeGestureRecognizer allocWithZone:[self zone]] initWithTarget:self action:@selector(handleSwipe:)];
	[swipeUpRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
	[view addGestureRecognizer:swipeUpRecognizer];
	[swipeUpRecognizer release];
	
	UISwipeGestureRecognizer* swipeDownRecognizer = [[UISwipeGestureRecognizer allocWithZone:[self zone]] initWithTarget:self action:@selector(handleSwipe:)];
	[swipeDownRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
	[view addGestureRecognizer:swipeDownRecognizer];
	[swipeDownRecognizer release];
	
	double interval = .1f;
	AVAsset* asset = [[mPlayer currentItem] asset];
	
	if (asset)
	{
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([mScrubber bounds]);
			interval = 0.5f * duration / width;
		}
	}

	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
		[mTimeObserver release];
	}
	
	mTimeObserver = [[mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
	^(CMTime time) {
		[self syncScrubber];
	}] retain];
	
	[self syncButtons];
	[self syncScrubber];
}

- (void)viewDidAppear:(BOOL)animated
{
	[mPlayer play];
	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[mPlayer pause];
	
	[super viewWillDisappear:animated];
}

-(void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
	UIView* view = [self view];
	UISwipeGestureRecognizerDirection direction = [gestureRecognizer direction];
	CGPoint location = [gestureRecognizer locationInView:view];
	
	if (location.y < CGRectGetMidY([view bounds]))
	{
		if (direction == UISwipeGestureRecognizerDirectionUp)
		{
			[UIView animateWithDuration:0.2f animations:
			^{
				[[self navigationController] setNavigationBarHidden:YES animated:YES];
			} completion:
			^(BOOL finished)
			{
				[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			}];
		}
		if (direction == UISwipeGestureRecognizerDirectionDown)
		{
			[UIView animateWithDuration:0.2f animations:
			^{
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
			} completion:
			^(BOOL finished)
			{
				[[self navigationController] setNavigationBarHidden:NO animated:YES];
			}];
		}
	}
	else
	{
		if (direction == UISwipeGestureRecognizerDirectionDown)
		{
			if (![mLowerUI isHidden])
			{
				[UIView animateWithDuration:0.2f animations:
				^{
					[mLowerUI setTransform:CGAffineTransformMakeTranslation(0.f, CGRectGetHeight([mLowerUI bounds]))];
				} completion:
				^(BOOL finished)
				{
					[mLowerUI setHidden:YES];
				}];
			}
		}
		if (direction == UISwipeGestureRecognizerDirectionUp)
		{
			if ([mLowerUI isHidden])
			{
				[mLowerUI setHidden:NO];
				
				[UIView animateWithDuration:0.2f animations:
				^{
					[mLowerUI setTransform:CGAffineTransformIdentity];
				} completion:^(BOOL finished){}];
			}
		}
	}
}

- (void)syncScrubber
{
	AVAsset* asset = [[mPlayer currentItem] asset];
	
	if (!asset)
		return;
	
	double duration = CMTimeGetSeconds([asset duration]);
	
	if (isfinite(duration))
	{
		float minValue = [mScrubber minimumValue];
		float maxValue = [mScrubber maximumValue];
		double time = CMTimeGetSeconds([mPlayer currentTime]);
		
		[mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
}

- (void)syncButtons
{
	if ([self isPlaying])
	{
		[mPauseBar setHidden:NO];
		[mPlayBar setHidden:YES];
	}
	else
	{
		[mPauseBar setHidden:YES];
		[mPlayBar setHidden:NO];
	}
}

- (void)play:(id)sender
{
	[mPlayer play];
}

- (void)pause:(id)sender
{
	[mPlayer pause];
}

- (BOOL)isPlaying
{
	return mRestoreAfterScrubbingRate != 0.f || [mPlayer rate] != 0.f;
}

- (void)beginScrubbing:(id)sender
{
	mRestoreAfterScrubbingRate = [mPlayer rate];
	[mPlayer setRate:0.f];
	
	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
		[mTimeObserver release];
		mTimeObserver = nil;
	}
}

- (void)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		AVAsset* asset = [[mPlayer currentItem] asset];
		
		if (!asset)
			return;
		
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			CGFloat width = CGRectGetWidth([slider bounds]);
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			double tolerance = 0.5f * duration / width;
			
			[mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)];
		}
	}
}

- (void)endScrubbing:(id)sender
{
	if (!mTimeObserver)
	{
		AVAsset* asset = [[mPlayer currentItem] asset];
		
		if (!asset)
			return;
		
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([mScrubber bounds]);
			double tolerance = 0.5f * duration / width;
			
			mTimeObserver = [[mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
			^(CMTime time)
			{
				[self syncScrubber];
			}] retain];
		}
	}

	if (mRestoreAfterScrubbingRate)
	{
		[mPlayer setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
}

- (BOOL)isScrubbing
{
	return mRestoreAfterScrubbingRate != 0.f;
}



- (void)observeValueForKeyPath:(NSString*) path ofObject:(id) object change:(NSDictionary*)change context:(void*)context
{
	if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
	{
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self syncButtons];
		});
	}
	else if (context == AVPlayerDemoPlaybackViewControllerDurationObservationContext)
	{
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self syncScrubber];
		});
	}
	else
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
}

- (void) done:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
}

@end

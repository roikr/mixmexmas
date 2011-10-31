//
//  ExportManager.m
//  Milgrom
//
//  Created by Roee Kremer on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ExportManager.h"
#import <AVFoundation/AVFoundation.h>

@interface ExportManager ()
@property (nonatomic, retain) AVAssetExportSession *session;
@end


@implementation ExportManager

@synthesize session;


+ (id) exportAudio:(NSURL*)audioURL toURL:(NSURL*)url withCompletionHandler:(void (^)(void))completionHandler {
	
	ExportManager * manager = [[[self alloc] init ] autorelease];
	
	NSString *exportPath = [url path];
	NSError *error = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:exportPath error:&error]) {
			NSLog(@"removeItemAtPath error: %@",[error description]);
		}
	}
	
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],AVURLAssetPreferPreciseDurationAndTimingKey,nil];
	AVURLAsset *audio = [AVURLAsset URLAssetWithURL:audioURL options:options];
	// TODO: the options is key issue because it get you duration synchrouniously so the session can finish asynch
	
	manager.session = [AVAssetExportSession exportSessionWithAsset:audio presetName:AVAssetExportPresetAppleM4A]; 
	
	manager.session.outputURL = url;
	manager.session.outputFileType = AVFileTypeAppleM4A;
	
	
	[manager.session exportAsynchronouslyWithCompletionHandler:^
	 {
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler();	
		});
	 }];
	
	
	return manager;
}

- (BOOL)didFinish {
	return [session status] != AVAssetExportSessionStatusExporting;
}

- (float)progress {
	return [session progress];
}

- (void) cancelExport {
	[session cancelExport];
}

- (BOOL) didExportComplete {
	return [session status] == AVAssetExportSessionStatusCompleted;

}


- (void)dealloc {
    [super dealloc];
}


/*
+ (AVAssetExportSession *)exportToURL:(NSURL*)url withVideoURL:(NSURL*)videoURL withAudioURL:(NSURL*)audioURL 
				  withProgressHandler:(void (^)(float))progressHandler withCompletionHandler:(void (^)(void))completionHandler {
	
	
	AVMutableComposition *composition = [AVMutableComposition composition];
	
	AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],AVURLAssetPreferPreciseDurationAndTimingKey,nil];
	AVURLAsset *video = [AVURLAsset URLAssetWithURL:videoURL options:options];
	AVURLAsset *audio = [AVURLAsset URLAssetWithURL:audioURL options:options];
	// TODO: the options is key issue because it get you duration synchrouniously so the session can finish asynch
	
	CMTimeRange audioTimeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [audio duration]);
	CMTimeRange videoTimeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [video duration]);
	
	//CMTimeRange timeRange = CMTimeRangeGetIntersection(audioTimeRangeInAsset, videoTimeRangeInAsset);
	
	NSError *error;
	NSArray *videoTracks = [video tracksWithMediaType:AVMediaTypeVideo];
	
	AVAssetTrack *clipVideoTrack = [ videoTracks objectAtIndex:0];
	[compositionVideoTrack insertTimeRange:videoTimeRangeInAsset ofTrack:clipVideoTrack atTime:kCMTimeZero error:&error];
	
	
	AVAssetTrack *clipAudioTrack = [[audio tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
	[compositionAudioTrack insertTimeRange:audioTimeRangeInAsset ofTrack:clipAudioTrack atTime:kCMTimeZero error:&error];
	
	
	AVAssetExportSession *session = [[[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality] retain]; // AVAssetExportPresetPassthrough
	
	session.outputURL = url;
	session.outputFileType = AVFileTypeQuickTimeMovie;
	session.audioMix = nil;
	session.metadata = nil;
	session.videoComposition = nil;
	session.timeRange = audioTimeRangeInAsset;
	
	
	
	//session.videoComposition = videoComposition;
	
	[session exportAsynchronouslyWithCompletionHandler:^
	 {
		 
		 //NSLog(@"export did finished with status: %i",[session status]);
		 dispatch_async(dispatch_get_main_queue(), ^{
			 completionHandler();
		 });
		 
	 }];
	
	
	//	dispatch_queue_t myCustomQueue;
	//	myCustomQueue = dispatch_queue_create("exportQueue", NULL);
	//	
	//	dispatch_async(myCustomQueue, ^{
	//		while ([session status] != AVAssetExportSessionStatusCompleted) {
	//			progressHandler([session progress]);
	//			//[NSThread sleepForTimeInterval:0.04f];
	//		}
	//	});
	//	
	//	
	//	dispatch_release(myCustomQueue);
	
	
	return session ;
	
}
*/


/*

- (void)updateExportProgress:(AVAssetExportSession *)theSession
{
	
	if ([theSession status]==AVAssetExportSessionStatusExporting) {
		
		self.progress = [NSNumber numberWithFloat:[theSession progress]];
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateExportProgress:) withObject:theSession afterDelay:0.1 inModes:modes];
	} else {
		self.progress = [NSNumber numberWithFloat:1.0f];
	}
	
	
	
}

- (void)exportDidFinish {
	MilgromViewController * milgromViewController = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).milgromViewController;
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	OFSAptr->setSongState(SONG_IDLE);
	OFSAptr->soundStreamStart();
	
	
	NSLog(@"exportDidFinish");
	
}
*/
@end

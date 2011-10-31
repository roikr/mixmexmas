//
//  OpenGLTOMovie.h
//  ConvertToVideo
//
//  Created by Roee Kremer on 8/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>


@class AVAssetExportSession;
	

@interface OpenGLTOMovie : NSObject {
	int state;
}

+(id)renderManager;
-(void)writeToVideoURL:(NSURL*)videoURL withAudioURL:(NSURL*)audioURL withContext:(EAGLContext *)contextA withSize:(CGSize)size 
	withAudioAverageBitRate:(NSNumber *)audioBitrate
	withVideoAverageBitRate:(NSNumber *)videoBitrate
	withInitializationHandler:(void (^)(void))initializationHandler 
		  withDrawFrame:(void (^)(int))drawFrame 
		  withIsRendering:(int (^)(void))isRendering
		withCompletionHandler:(void (^)(void))completionHandler
	withCancelationHandler:(void (^)(void))cancelationHandler
	withAbortionHandler:(void (^)(void))abortionHandler;
//+ (AVAssetExportSession *)exportToURL:(NSURL*)url withVideoURL:(NSURL*) videoURL withAudioURL:(NSURL*)audioURL 
//					withProgressHandler:(void (^)(float))progressHandler withCompletionHandler:(void (^)(void))completionHandler;


- (void) cancelRender;
- (void) abortRender;
@end

//
//  RenderManager.h
//  SingingCard
//
//  Created by Roee Kremer on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ExportManager;
@class OpenGLTOMovie;
@class RenderProgressView;

@protocol RenderManagerDelegate;

@interface RenderManager : NSObject {
	id<RenderManagerDelegate> delegate;
	
	ExportManager *exportManager;
	OpenGLTOMovie *renderer;
	RenderProgressView *renderProgressView;
}


@property (nonatomic, retain) ExportManager *exportManager;
@property (nonatomic, retain) OpenGLTOMovie *renderer;
@property (nonatomic, retain) RenderProgressView *renderProgressView;

-(void)setDelegate:(id<RenderManagerDelegate>)theDelegate;
- (void)renderAudio;
- (void)renderVideo;
- (void)exportRingtone;
- (void)cancelRendering:(id)sender;
- (void)applicationDidEnterBackground;

@end

@protocol RenderManagerDelegate<NSObject> 

- (void) renderManagerRenderCanceled:(RenderManager *)manager;
- (void) renderManagerAudioRendered:(RenderManager *)manager;
- (void) renderManagerVideoRendered:(RenderManager *)manager;
- (void) renderManagerRingtoneExported:(RenderManager *)manager;
- (void) renderManagerProgress:(float)progress;

@end





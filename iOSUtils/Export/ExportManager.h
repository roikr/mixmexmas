//
//  ExportManager.h
//  Milgrom
//
//  Created by Roee Kremer on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AVAssetExportSession;

@interface ExportManager : NSObject {
	AVAssetExportSession *session;
}

@property (readonly) BOOL didFinish;
@property (readonly) float progress;

+ (id) exportAudio:(NSURL*)audioURL toURL:(NSURL*)url withCompletionHandler:(void (^)(void))completionHandler;
- (void) cancelExport;
- (BOOL) didExportComplete;
@end

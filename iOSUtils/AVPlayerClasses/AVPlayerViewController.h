//
//  AVPlayerViewController.h
//  SingingCard
//
//  Created by Roee Kremer on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AVPlayerViewControllerDelegate;


@class AVPlayer;
@class AVPlayerItem;

@interface AVPlayerViewController : UIViewController {
	
	id<AVPlayerViewControllerDelegate> delegate;
	AVPlayer* player;
	UIImageView *imageView;
	
		
}

@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, assign) id<AVPlayerViewControllerDelegate> delegate;


-(void)loadAssetFromURL:(NSURL *)fileURL;
-(IBAction)skip:(id)sender;
 

@end

@protocol AVPlayerViewControllerDelegate

-(void) AVPlayerLayerIsReadyForDisplay:(AVPlayerViewController*)controller;
-(void) AVPlayerViewControllerDone:(AVPlayerViewController*)controller;

@end
//
//  RenderProgressView.h
//  SingingCard
//
//  Created by Roee Kremer on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomImageView;

@interface RenderProgressView : UIView {
	CustomImageView *progressView;
	UIButton *cancelButton;
}

@property (nonatomic,retain ) IBOutlet CustomImageView *progressView;
@property (nonatomic,retain ) IBOutlet UIButton *cancelButton;

-(void)setRenderProgress:(float)progress;


@end

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
    UILabel *titleLabel;
}

@property (nonatomic,retain ) IBOutlet CustomImageView *progressView;
@property (nonatomic,retain ) IBOutlet UIButton *cancelButton;
@property (nonatomic,retain ) IBOutlet UILabel *titleLabel;

-(void)setRenderProgress:(float)progress;


@end

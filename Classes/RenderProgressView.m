//
//  RenderProgressView.m
//  SingingCard
//
//  Created by Roee Kremer on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RenderProgressView.h"
#import "CustomImageView.h"

@implementation RenderProgressView

@synthesize progressView;
@synthesize cancelButton;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void)setRenderProgress:(float)progress {
//	self.progressView.progress = progress;
	[progressView setRect:CGRectMake(0.0f, 0.0f,progress,1.0f)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end

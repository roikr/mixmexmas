//
//  RenderView.m
//  ConvertToVideo
//
//  Created by Roee Kremer on 11/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RenderView.h"
#import <QuartzCore/QuartzCore.h>


@implementation RenderView


+(RenderView *) renderViewWithFrame:(CGRect)frame {
	return [[[RenderView alloc] initWithFrame:frame] autorelease];
}

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
		
    }
    return self;
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

//
//  UICustomImageView.m
//  Milgrom
//
//  Created by Roee Kremer on 8/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomImageView.h"


@implementation CustomImageView

@synthesize image;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder]) {
	
	}
	
	return self;
}

- (CGRect) rect {
	return _rect;
}

- (void)setRect:(CGRect)rect {
	_rect = rect;
	if (self.image) {
		[self setNeedsDisplay];
	}
	
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	//create a context to do our clipping in
	if (self.image) {	
		UIGraphicsBeginImageContext(rect.size);
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		
		//create a rect with the size we want to crop the image to
		//the X and Y here are zero so we start at the beginning of our
		//newly created context	
		CGRect clipRect = CGRectMake(image.size.width*_rect.origin.x, image.size.height*_rect.origin.y, image.size.width*_rect.size.width, image.size.height*_rect.size.height);
		CGContextClipToRect( currentContext, clipRect);
		
		//create a rect equivalent to the full size of the image
		//offset the rect by the X and Y we want to start the crop
		//from in order to cut off anything before them
		CGRect drawRect = CGRectMake(0,
									 0,
									 image.size.width,
									 image.size.height);
		
		//draw the image to our clipped context using our offset rect
		
		CGContextTranslateCTM (currentContext, 0,  image.size.height);
		CGContextScaleCTM (currentContext, 1.0, -1.0);
		CGContextDrawImage(currentContext, drawRect, image.CGImage);
		
		//pull the image from our cropped context
		UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
		
		//pop the context to get back to the default
		UIGraphicsEndImageContext();
		
		[cropped drawInRect:rect];
	}
}


- (void)dealloc {
    [super dealloc];
}


@end

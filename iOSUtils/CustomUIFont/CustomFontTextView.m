//
//  CustomFontTextView.m
//  Milgrom
//
//  Created by Roee Kremer on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomFontTextView.h"


@implementation CustomFontTextView


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
		[self setFont: [UIFont fontWithName: @"FbKomic-Regular" size: self.font.pointSize]]; 
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
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

//
//  CustomButton.m
//  Milgrom
//
//  Created by Roee Kremer on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomButton.h"


@implementation CustomButton


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
//        for (NSString *family in [UIFont familyNames]) {
//            for (NSString *font in [UIFont fontNamesForFamilyName:family]) {
//                NSLog(@"%@,%@",family,font);
//            }
//
//        }
        
        self.titleLabel.font = [UIFont fontWithName: @"BritannicBold" size: self.titleLabel.font.pointSize];
		
    }
    return self;
}

//- (id)initWithFrame:(CGRect)frame {
//    
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code.
//    }
//    return self;
//}

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

//
//  UICustomImageView.h
//  Milgrom
//
//  Created by Roee Kremer on 8/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomImageView : UIView {
	UIImage *image;
	CGRect _rect;
}

@property (nonatomic,retain) UIImage *image;
@property CGRect rect;

@end

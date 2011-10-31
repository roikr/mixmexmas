//
//  TouchView.h
//  Milgrom
//
//  Created by Roee Kremer on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define	OF_MAX_TOUCHES			5		// iphone has max 5 finger support

@interface TouchView : UIView {
	UITouch					*activeTouches[OF_MAX_TOUCHES];
}


@end

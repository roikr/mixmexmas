//
//  TouchView.m
//  Milgrom
//
//  Created by Roee Kremer on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TouchView.h"
#import "SingingCardAppDelegate.h"
#import "testApp.h"
#import "Constants.h"
#import "MainViewController.h"
//#import "MilgromMacros.h"

@implementation TouchView




- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        bzero(activeTouches, sizeof(activeTouches));

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/******************* TOUCH EVENTS ********************/
//------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
	//	NSLog(@"touchesBegan: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	SingingCardAppDelegate *appDelegate = (SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!appDelegate.OFSAptr) {
		return;
	}
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && activeTouches[touchIndex] != 0) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesBegan - weird!");
			touchIndex=0;	
		}
		
		activeTouches[touchIndex] = touch;
		
		CGPoint touchPoint = [touch locationInView:self];
		
		ofTouchEventArgs t;
		t.x = touchPoint.x;
		t.y = touchPoint.y;
		t.id = touchIndex;
		
		if([touch tapCount] == 2) {

			appDelegate.OFSAptr->touchDoubleTap(t);// send doubletap
		}
		
		//if([touch tapCount] >= 1) {
			
		appDelegate.OFSAptr->touchDown(t);
		//}
		
		/*
		 if([touch tapCount] == 1) 
		 controller.OFSAptr->touchDown(touchPoint.x, touchPoint.y, touchIndex);
		 else 
		 controller.OFSAptr->touchDoubleTap(touchPoint.x, touchPoint.y, touchIndex);
		 */
	}
}

//------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//	NSLog(@"touchesMoved: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	SingingCardAppDelegate *appDelegate = (SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!appDelegate.OFSAptr) {
		return;
	}
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesMoved - weird!");
			continue;	
		}
		
		CGPoint touchPoint = [touch locationInView:self];
		
		ofTouchEventArgs t;
		t.x = touchPoint.x;
		t.y = touchPoint.y;
		t.id = touchIndex;
		
		appDelegate.OFSAptr->touchMoved(t);
	}
}

//------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
		
	//	NSLog(@"touchesEnded: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	
	SingingCardAppDelegate *appDelegate = (SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!appDelegate.OFSAptr) {
		return;
	}
	
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesEnded - weird!");
			continue;	
		}
		
		activeTouches[touchIndex] = 0;
		
		CGPoint touchPoint = [touch locationInView:self];
		
		ofTouchEventArgs t;
		t.x = touchPoint.x;
		t.y = touchPoint.y;
		t.id = touchIndex;
	
//		int mode = appDelegate.OFSAptr->getMode(appDelegate.OFSAptr->controller);
		appDelegate.OFSAptr->touchUp(t);
		
//		if (mode!=appDelegate.OFSAptr->getMode(appDelegate.OFSAptr->controller)) {
//			[viewController updateViews];
//		}
	}
}

//------------------------------------------------------
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	SingingCardAppDelegate *appDelegate = (SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!appDelegate.OFSAptr) {
		return;
	}
	
	for(int i=0; i<OF_MAX_TOUCHES; i++){
		if(activeTouches[i]){
			
			CGPoint touchPoint = [activeTouches[i] locationInView:self];
			activeTouches[i] = 0;
			
			ofTouchEventArgs t;
			t.x = touchPoint.x;
			t.y = touchPoint.y;
			t.id = i;
			
			appDelegate.OFSAptr->touchUp(t);
			
		}
	}
}





- (void)dealloc {
	[super dealloc];
}


@end

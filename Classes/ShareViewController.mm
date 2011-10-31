//
//  ShareViewController.m
//  SingingCard
//
//  Created by Roee Kremer on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "SingingCardAppDelegate.h"
#import "ShareManager.h"
#import "RKMacros.h"

@interface ShareViewController() 
@end


@implementation ShareViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark actionSheet

- (void) action:(id)sender {
	
	UIButton *button = (UIButton *)sender;
		switch (button.tag)
	{
		case 0: 
			action = ACTION_UPLOAD_TO_FACEBOOK;
			break;
		case 1:
			action = ACTION_SEND_VIA_MAIL;
			break;			
		case 2:
			action = ACTION_UPLOAD_TO_YOUTUBE;
			break;
		case 3:
			action = ACTION_ADD_TO_LIBRARY;
			break;
		case 4:
			action = ACTION_SEND_RINGTONE;
			break;
		case 5:
			action = ACTION_CANCEL;
			break;
	}
	
	
	[self dismissModalViewControllerAnimated:YES]; // action==ACTION_CANCEL
	
	
}

- (void)viewDidDisappear:(BOOL)animated {	
	[((SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate]).shareManager performAction:action];
}

@end

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
       
            switch (button.tag) {
                case ACTION_UPLOAD_TO_FACEBOOK: 
                    [button setTitle:NSLocalizedString(@"SM facebook",@"Post on Facebook") forState:UIControlStateNormal];
                    break;
                case ACTION_SEND_VIA_MAIL:
                    [button setTitle:NSLocalizedString(@"SM email",@"Send by Email") forState:UIControlStateNormal];
                    break;			
                case ACTION_UPLOAD_TO_YOUTUBE:
                    [button setTitle:NSLocalizedString(@"SM youtube",@"Upload to YouTube") forState:UIControlStateNormal];
                    break;
                case ACTION_ADD_TO_LIBRARY:
                    [button setTitle:NSLocalizedString(@"SM library",@"Save to photo library") forState:UIControlStateNormal];
                    break;
                case ACTION_SEND_RINGTONE:
                    [button setTitle:NSLocalizedString(@"SM ringtone",@"Send ringtone") forState:UIControlStateNormal];
                    break;
                case ACTION_CANCEL:
                    [button setTitle:NSLocalizedString(@"SM done",@"Done") forState:UIControlStateNormal];
                    break;
            }
        }
    }
}



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
  
    action = button.tag;
//    RKLog(@"ShareViewController::action: %i(%@)", button.tag,[ShareManager getActionName:action]);
    
	[self dismissModalViewControllerAnimated:YES]; // action==ACTION_CANCEL
		
}

- (void)viewDidDisappear:(BOOL)animated {	
	if (animated) { // otherwise it is entering background
        [((SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate]).shareManager performAction:action];
    }
}

@end

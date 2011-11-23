//
//  FacebookUploadViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploadViewController.h"

#define LOG_FACEBOOK_VIEW_CONTROLLER

@interface FacebookUploadViewController ()


@end

@implementation FacebookUploadViewController

@synthesize titleField;
@synthesize descriptionView;
@synthesize videoPath;
@synthesize activeView;
@synthesize scrollView;
@synthesize additionalText;
@synthesize bDelayedUpload;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	additionalText = @"";
	    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[videoPath release];
	[uploader release];
    [super dealloc];
}

-(void)setDelegate:(id<FacebookUploadViewControllerDelegate>)theDelegate {
	delegate = theDelegate;
}


-(void)setUploader:(FacebookUploader *) theUploader {
	uploader = theUploader;
	[theUploader addDelegate:self];
}

-(FacebookUploader *)uploader {
	return uploader;
}


-(void) setVideoTitle:(NSString *) title{
	titleField.text = title;
}

-(NSString *)videoTitle {
	return titleField.text;
}

/*
- (void) touchDown:(id)sender {
	NSLog(@"touchDown");
	for (UIView *view in [self.scrollView subviews]) {  
        if ([view isFirstResponder]) {  
            [view resignFirstResponder];
			break;
        }
    }   
}
 */

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	activeView = nil;
    [textField resignFirstResponder];
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
#ifdef LOG_FACEBOOK_VIEW_CONTROLLER
    NSLog(@"textFieldDidBeginEditing");
#endif
    activeView = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
#ifdef LOG_FACEBOOK_VIEW_CONTROLLER
    NSLog(@"textFieldDidEndEditing");
#endif
    activeView = nil;
}

- (void) closeTextView:(id)sender {
	
	if (activeView) {
        if (![activeView isFirstResponder]) {
            NSLog(@"but not first responder...");
        }
        [activeView resignFirstResponder];
    }
	
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
#ifdef LOG_FACEBOOK_VIEW_CONTROLLER
    NSLog(@"textViewDidBeginEditing");
#endif
    activeView = textView;
}


- (void)textViewDidEndEditing:(UITextView *)textView {
#ifdef LOG_FACEBOOK_VIEW_CONTROLLER
    NSLog(@"textViewDidEndEditing");
#endif
    activeView = nil;
}

// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardDidShow:(NSNotification*)aNotification
{
	NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    //    scrollView.contentInset = contentInsets;
    //    scrollView.scrollIndicatorInsets = contentInsets;
    
    //scrollView.contentSize=CGSizeMake(scrollView.frame.size.width,scrollView.frame.size.height+150);
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            scrollView.contentSize=CGSizeMake(scrollView.frame.size.width,scrollView.frame.size.height+kbSize.height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            scrollView.contentSize=CGSizeMake(scrollView.frame.size.width,scrollView.frame.size.height+kbSize.width);
            
            
            break;
            
        default:
            break;
    }
    
    _isKeyboardVisible = YES;
    [scrollView setContentOffset:CGPointMake(0.0, activeView.frame.origin.y-15) animated:YES];
    
}

- (void)keyboardDidHide:(NSNotification*)aNotification
{
	_isKeyboardVisible = NO;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)theScrollView {
#ifdef LOG_FACEBOOK_VIEW_CONTROLLER
    NSLog(@"scrollViewDidEndScrollingAnimation");
#endif
    if (!_isKeyboardVisible) {
        scrollView.contentSize=CGSizeMake(scrollView.frame.size.width,scrollView.frame.size.height);
    }
}


- (void) upload:(id)sender {
	if (uploader!=nil) {
		if ([uploader isConnected]) {
			[uploader setVideoTitle:titleField.text];
			[uploader setVideoDescription:[descriptionView.text stringByAppendingString:additionalText]];
			[uploader setVideoPath:videoPath];
			if (bDelayedUpload) {
				[delegate FacebookUploadViewControllerUpload:self];
			} else {
				[uploader upload];
			}

//			[uploader uploadVideoWithTitle:titleField.text withDescription:[descriptionView.text stringByAppendingString:additionalText] andPath:videoPath];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fb no login title",@"Facebook login") message:NSLocalizedString(@"fb no login body",@"You are not logged in. Please login to upload") delegate:nil  cancelButtonTitle:NSLocalizedString(@"ok button","OK")  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void) login:(id)sender {
	if (uploader!=nil) {
		if ([uploader isConnected]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fb login title",@"Facebook Login") message:NSLocalizedString(@"fb login body",@"You are already logged in") delegate:nil  cancelButtonTitle:NSLocalizedString(@"ok button","OK")  otherButtonTitles:nil];
			[alert show];
			[alert release];
		} else {
			[uploader login];
		}

	}
}

- (void) cancel:(id)sender {
	[delegate FacebookUploadViewControllerCancel:self];
}

- (void) logout:(id)sender {
	
	if (uploader!=nil) {
		[uploader logout];
//		if ([uploader isConnected]) {
//			[uploader logout];
//		} else {
//			[uploader login];
//		}

	}
}


- (void) facebookUploaderStateChanged:(FacebookUploader *)theUploader {
#ifdef LOG_FACEBOOK_VIEW_CONTROLLER
	NSLog(@"new state: %i, app state: %i",theUploader.state,[UIApplication sharedApplication].applicationState );
#endif
	if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
		return;
	}
	
	switch ([theUploader state]) {
		case FACEBOOK_UPLOADER_STATE_UPLOADING:
		case FACEBOOK_UPLOADER_STATE_UPLOAD_CANCELED:
			if (!bDelayedUpload) {
				[delegate FacebookUploadViewControllerUpload:self];
			}
			break;
		case FACEBOOK_UPLOADER_STATE_DID_NOT_LOGIN: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fb login failed title",@"Facebook Login") message:NSLocalizedString(@"fb login failed body",@"Logged in failed. Please try again") delegate:nil  cancelButtonTitle:NSLocalizedString(@"ok button","OK")  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}	break;
		default:
			break;
	}
}

@end

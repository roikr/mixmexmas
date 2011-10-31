//
//  FacebookUploadViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploadViewController.h"
#import "FacebookUploader.h"

@interface FacebookUploadViewController ()


@end

@implementation FacebookUploadViewController

@synthesize titleField;
@synthesize descriptionView;
@synthesize videoPath;
@synthesize activeView;
@synthesize scrollView;
@synthesize additionalText;
@synthesize keyboardButton;
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
	scrollView.contentSize=CGSizeMake(scrollView.frame.size.width,scrollView.frame.size.height+100);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSLog(@"FacebookUploadViewController::viewWillAppear");
	[scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
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

- (void) touchDown:(id)sender {
	NSLog(@"touchDown");
	for (UIView *view in [self.scrollView subviews]) {  
        if ([view isFirstResponder]) {  
            [view resignFirstResponder];
			break;
        }
    }   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}




- (void) closeTextView:(id)sender {
	
	if ([descriptionView isFirstResponder]) {  
		[descriptionView resignFirstResponder];
	}
	
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	keyboardButton.hidden = NO;
}


- (void)textViewDidEndEditing:(UITextView *)textView {
	keyboardButton.hidden = YES;
}


- (void)keyboardDidHide:(NSNotification*)aNotification
{
	[scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	
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
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Upload" message:@"You are not logged in. Please login to upload" delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void) login:(id)sender {
	if (uploader!=nil) {
		if ([uploader isConnected]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login" message:@"You are already logged in" delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles:nil];
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
	NSLog(@"new state: %i, app state: %i",theUploader.state,[UIApplication sharedApplication].applicationState );
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
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login" message:@"Logged in failed. Please login to upload" delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}	break;
		default:
			break;
	}
}

@end

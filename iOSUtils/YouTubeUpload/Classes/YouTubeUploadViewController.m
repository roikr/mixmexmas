//
//  YouTubeUploadViewController.m
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploadViewController.h"

@interface YouTubeUploadViewController (PrivateMethods)

- (void)unsave;
@end

@implementation YouTubeUploadViewController

//#define LOG_YOUTUBE_VIEW_CONTROLLER

@synthesize username;
@synthesize password;
@synthesize titleField;
@synthesize descriptionView;
@synthesize videoPath;
@synthesize scrollView;
@synthesize additionalText;
@synthesize processView;
@synthesize bDelayedUpload;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	username.text = [defaults objectForKey:@"YTUsername"];
	password.text = [defaults objectForKey:@"YTPassword"];
	additionalText = @"";
	
	
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[videoPath release];
	[uploader release];
    [super dealloc];
}

-(void)setDelegate:(id<YouTubeUploadViewControllerDelegate>)theDelegate {
	delegate = theDelegate;
}


-(void)setUploader:(YouTubeUploader *) theUploader {
	uploader = theUploader;
	[theUploader addDelegate:self];
}

-(YouTubeUploader *)uploader {
	return uploader;
}

-(void) setVideoTitle:(NSString *) title{
	titleField.text = title;
}

-(NSString *)videoTitle {
	return titleField.text;
}



- (void)unsave {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"YTUsername"];
	[defaults removeObjectForKey:@"YTPassword"];
	[defaults synchronize];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}



//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//	[scrollView scrollRectToVisible:textField.frame animated:YES];
//	return YES;
//}
//
- (void)textFieldDidBeginEditing:(UITextField *)textField {
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER
    NSLog(@"textFieldDidBeginEditing");
#endif
    activeView = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField==username) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		if (username.text!=@"") {
			[defaults setObject:username.text forKey:@"YTUsername"];
		} else {
			[defaults removeObjectForKey:@"YTUsername"];
		}
		
		[defaults synchronize];
		
	}
	
	if (textField==password) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		if (password.text!=@"") {
			[defaults setObject:password.text forKey:@"YTPassword"];
		} else {
			[defaults removeObjectForKey:@"YTPassword"];
		}
		
		[defaults synchronize];
		
	}
	
	
	return YES;
	
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER
    NSLog(@"textFieldDidEndEditing");
#endif
    activeView = nil;
}


- (void) closeTextView:(id)sender {
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER
	NSLog(@"closeTextView");
#endif
    if (activeView) {
        [activeView resignFirstResponder];
    }
//	if ([descriptionView isFirstResponder]) {  
//		[descriptionView resignFirstResponder];
//	}
	
}

/*
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	[scrollView scrollRectToVisible:textView.frame animated:YES];
	return YES;
}
*/

- (void)textViewDidBeginEditing:(UITextView *)textView {
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER
    NSLog(@"textViewDidBeginEditing");
#endif
    activeView = textView;
}


- (void)textViewDidEndEditing:(UITextView *)textView {
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER
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



// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardDidHide:(NSNotification*)aNotification
{
	_isKeyboardVisible = NO;
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES]; 
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)theScrollView {
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER
    NSLog(@"scrollViewDidEndScrollingAnimation");
#endif
    if (!_isKeyboardVisible) {
        scrollView.contentSize=CGSizeMake(scrollView.frame.size.width,scrollView.frame.size.height);
    }
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging, willDecelerate: %i",decelerate);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
}
*/


- (void) upload:(id)sender {
    [self closeTextView:nil];
	
	if (uploader!=nil) {
		uploader.username = username.text;
		uploader.password = password.text;
		[uploader setVideoTitle:titleField.text];
		[uploader setVideoDescription:[descriptionView.text stringByAppendingString:additionalText]];
		[uploader setVideoPath:videoPath];
		
		if (bDelayedUpload) {
			[delegate YouTubeUploadViewControllerUpload:self];
		} else {
			[uploader upload];
		}

//		[uploader uploadVideoWithTitle:titleField.text withDescription:descriptionView.text andPath:videoPath]; //[descriptionView.text stringByAppendingString:additionalText]
	}
		
}

- (void) cancel:(id)sender {
    [self closeTextView:nil];
	[delegate YouTubeUploadViewControllerCancel:self];
}


- (void) youTubeUploaderStateChanged:(YouTubeUploader *)theUploader {
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER	
	NSLog(@"YouTubeUploadViewController new state: %i, app state: %i",theUploader.state,[UIApplication sharedApplication].applicationState );
#endif	
	
	if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
		return;
	}
				
	processView.hidden = YES;
	
	switch (theUploader.state) {
		case YOUTUBE_UPLOADER_STATE_INCORRECT_CREDENTIALS: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"yt login failed title",@"YouTube error")
															message:NSLocalizedString(@"yt login failed body",@"Login failed, please check that the\nusername and password are correct")
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"ok button","OK") 
												  otherButtonTitles: nil];
			[alert show];
			[alert release];
		} break;
		
		case YOUTUBE_UPLOADER_STATE_UPLOAD_REQUESTED:
			processView.hidden = NO;
			break;

			
		case YOUTUBE_UPLOADER_STATE_UPLOADING:
			processView.hidden = NO;
			if (!bDelayedUpload) {
				[delegate YouTubeUploadViewControllerUpload:self];
			}
			
			break;
			
		default:
			break;
	}
	
	
	
	
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
#ifdef LOG_YOUTUBE_VIEW_CONTROLLER
	NSLog(@"YouTubeUploadViewController::viewWillAppear");
#endif
	[scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
	processView.hidden = uploader.state != YOUTUBE_UPLOADER_STATE_UPLOAD_REQUESTED && uploader.state != YOUTUBE_UPLOADER_STATE_UPLOADING;
//	scrollView.scrollEnabled = NO;
}



@end

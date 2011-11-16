//
//  ShareManager.m
//  Milgrom
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ShareManager.h"
#import "MainViewController.h"
#import "SingingCardAppDelegate.h"
#import "RKMacros.h"
#import "YouTubeUploadViewController.h"
#import "FacebookUploadViewController.h"

#import "testApp.h"
#import "Constants.h"
#import "Reachability.h"
#import "ShareViewController.h"

#ifdef _FLURRY
#import "FlurryAnalytics.h"
#endif

enum {
	STATE_IDLE,
	STATE_SELECTED,
	STATE_DONE,
	STATE_CANCELED
};



void ShareAlert(NSString *title,NSString *message) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


@interface ShareManager ()
- (void)sendViaMailWithSubject:(NSString *)subject withMessage:(NSString*)message 
					  withData:(NSData *)data withMimeType:(NSString*) mimeType withFileName:(NSString*)fileName;
- (void)exportToLibrary;
- (void)setVideoRendered;
- (void)setRingtoneExported;
- (BOOL)gotInternet;
- (void)proceedWithAudio;
- (void)proceedWithVideo;
- (void)sendRingtone;


@end

@implementation ShareManager

@synthesize facebookUploader;
@synthesize youTubeUploader;
@synthesize parentViewController;
@synthesize renderManager;

@synthesize youtubeLink;


+ (ShareManager*) shareManager {
	
	return  [[[ShareManager alloc] init] autorelease];
}

- (id)init {
	
	if (self = [super init]) {
		self.youTubeUploader = [YouTubeUploader youTubeUploader:@"AI39si7UINMeywyTjpdwb6jsPyw3nTy7NXLZr-ddXph5dEXf0q4ZNAvu_8BXwKU3AnxsTMglvjcpdQNfIoesABb6RYbo0bDeHw"];
		[youTubeUploader addDelegate:self];
		self.facebookUploader = [FacebookUploader facebookUploader:@"218795661526558"];
		[facebookUploader addDelegate:self];
		self.renderManager = [[[RenderManager alloc] init] autorelease];
		[renderManager setDelegate:self];
		
		canSendMail = [MFMailComposeViewController canSendMail];
		
		[self resetVersions];
		
		self.parentViewController =  ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
	}
	return self;
}

- (void)dealloc {
	[renderManager release];
    [super dealloc];
}


- (BOOL)gotInternet {
	
	RKLog(@"ShareManager::checkInternet Testing Internet Connectivity");
	Reachability *r = [Reachability reachabilityForInternetConnection];
	
	RKLog(@"ShareManager::checkInternet %i",[r currentReachabilityStatus] != NotReachable);
	return [r currentReachabilityStatus] != NotReachable;
}

-(BOOL) isUploading {
	return facebookUploader.state == FACEBOOK_UPLOADER_STATE_UPLOADING || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOADING;
}

- (void)setAudioRendered {
	renderedAudioVersion = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->getSongVersion();
}


- (BOOL)audioRendered {
	return renderedAudioVersion == ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->getSongVersion();
}



- (void)setVideoRendered {
	renderedVideoVersion = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->getSongVersion();
}


- (BOOL)videoRendered {
	return renderedVideoVersion == ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->getSongVersion();
}


- (void)setRingtoneExported {
	exportedRingtoneVersion = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->getSongVersion();
}


- (BOOL)ringtoneExported {
	return exportedRingtoneVersion == ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->getSongVersion();
}


- (NSString *)getExoprtFileame {
    
	testApp *OFSAptr = ((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
    
    return  [NSString stringWithCString:OFSAptr->citer->exportFilename.c_str() encoding:[NSString defaultCStringEncoding]];
		
}

- (NSString *)getDisplayName {
	return [self getExoprtFileame];
		
}

- (NSString *)getVideoPath {
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		RKLog(@"Documents directory not found!");
		return @"";
	}
		
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:[self getExoprtFileame]];
}



#pragma mark mailClass


- (void)sendViaMailWithSubject:(NSString *)subject withMessage:(NSString*)message
					  withData:(NSData *)data withMimeType:(NSString*) mimeType withFileName:(NSString*)fileName {
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:subject];
        if (data) {
            [picker addAttachmentData:data mimeType:mimeType fileName:fileName];
        }
		[picker setMessageBody:message isHTML:YES];
		[parentViewController presentModalViewController:picker animated:YES];
		[picker release];

	}
	
}




// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//appDelegate.toolbar.hidden = NO;
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent: {
			//message.text = @"Result: sent";
#ifdef _FLURRY
            [FlurryAnalytics logEvent:@"SHARE_DONE" withParameters:[NSDictionary dictionaryWithObject:[self getCurrentActionName] forKey:@"TARGET"]];
#endif
			
        } break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[parentViewController dismissModalViewControllerAnimated:YES];
	
}


#pragma mark Uploaders delegates

- (void) facebookUploaderStateChanged:(FacebookUploader *)theUploader {
	switch (theUploader.state) {
		case FACEBOOK_UPLOADER_STATE_UPLOAD_FINISHED: {
			ShareAlert(NSLocalizedString(@"FB alert",@"Facebook upload"),NSLocalizedString(@"FB upload finished", @"Your video was uploaded successfully!\ngo check your wall"));
#ifdef _FLURRY
            [FlurryAnalytics logEvent:@"SHARE_DONE" withParameters:[NSDictionary dictionaryWithObject:[self getCurrentActionName] forKey:@"TARGET"]];
#endif
		} break;
		case FACEBOOK_UPLOADER_STATE_UPLOADING: {
			ShareAlert(NSLocalizedString(@"FB alert",@"Facebook upload"),NSLocalizedString(@"FB upload progress", @"Upload is in progress"));

		} break;
		default:
			break;
	}
	
	[((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController updateViews];
		
}

- (void) facebookUploaderProgress:(float)progress {
	[[(SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}


-(void) youTubeUploaderStateChanged:(YouTubeUploader *)theUploader{
	switch (theUploader.state) {
		case YOUTUBE_UPLOADER_STATE_UPLOAD_FINISHED: {
#ifdef _FLURRY
            [FlurryAnalytics logEvent:@"SHARE_DONE" withParameters:[NSDictionary dictionaryWithObject:[self getCurrentActionName] forKey:@"TARGET"]];
#endif
            
//			ShareAlert(NSLocalizedString(@"YT alert",@"YouTube upload"), [NSString stringWithFormat:NSLocalizedString(@"YT upload finished",@"your video was uploaded successfully! link: %@"),[theUploader.link absoluteString]]); // ",]);
            self.youtubeLink = [theUploader.link absoluteString];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YT alert",@"YouTube upload") message:NSLocalizedString(@"YT upload finished",@"your video was uploaded successfully! do you want to share the link ?") delegate:self  cancelButtonTitle:NSLocalizedString(@"NO thanks button",@"No Thanks")  otherButtonTitles: NSLocalizedString(@"OK button",@"OK"),nil];
        
            [alert show];
            [alert release];


		} break;
		case YOUTUBE_UPLOADER_STATE_UPLOADING: {
			ShareAlert(NSLocalizedString(@"YT alert",@"YouTube upload"), NSLocalizedString(@"YT upload progress",@"Upload is in progress"));			
			
		} break;
		case YOUTUBE_UPLOADER_STATE_UPLOAD_STOPPED: {
			ShareAlert(NSLocalizedString(@"YT alert",@"YouTube upload") , NSLocalizedString(@"YT upload stopped",@"your upload has been stopped"));
		} break;
			
		default:
			break;
	}
	
	[((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController updateViews];
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil)
        {
            action = ACTION_SEND_YOUTUBE_LINK;
            state = STATE_DONE;

            // We must always check whether the current device is configured for sending emails
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            [picker setSubject:NSLocalizedString(@"YT email title",@"Sweeeet! My Xmas Greeting!")];
            
           
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"YT email message",@"Hey,<br/>I just made a xmas greeting created with the help of this cool app.<br/>click the <a href='%@'>link</a> to watch<br/><br/><br/><a href='http://www.lofipeople.com/mixmexmas/appstore'>MixMeXmas iPhone app</a>."),youtubeLink];
                                                                             
            [picker setMessageBody:message isHTML:YES];
            
            [((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController presentModalViewController:picker animated:YES];
        
            [picker release];
            
            
            
#ifdef _FLURRY
            [FlurryAnalytics logEvent:@"SHARE_MENU" withParameters:[NSDictionary dictionaryWithObject:[self getCurrentActionName] forKey:@"TARGET"] ];
#endif
            
        }
    }
    
}


- (void) youTubeUploaderProgress:(float)progress {
	[(MainViewController *)[(SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}

#pragma mark Action

- (void)resetVersions {
	
	renderedAudioVersion = 0;
	renderedVideoVersion = 0;
	exportedRingtoneVersion = 0;
}
						
				


- (void)renderAudio {
	state = STATE_IDLE;
	SingingCardAppDelegate *appDelegate = (SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if (![self audioRendered]) {
		appDelegate.mainViewController.view.userInteractionEnabled = NO;
		[renderManager renderAudio];
	} else {
		[appDelegate.mainViewController presentModalViewController:appDelegate.shareViewController animated:YES];
	}
	
	
	
	
}

- (void) renderManagerAudioRendered:(RenderManager *)manager {
	
	RKLog(@"renderManagerAudioRendered");
	[self setAudioRendered];
	
	SingingCardAppDelegate *appDelegate = (SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.mainViewController.view.userInteractionEnabled = YES;
	[appDelegate.mainViewController presentModalViewController:appDelegate.shareViewController animated:YES];
	
	
}

- (NSString *)getCurrentActionName {
    NSString *name;
   
    switch (action) {
        case ACTION_UPLOAD_TO_FACEBOOK: 
            name = @"FACEBOOK";
            break;
        case ACTION_SEND_VIA_MAIL:
            name = @"EMAIL";
            break;			
        case ACTION_UPLOAD_TO_YOUTUBE:
            name = @"YOUTUBE";
            break;
        case ACTION_ADD_TO_LIBRARY:
            name = @"LIBRARY";
            break;
        case ACTION_SEND_RINGTONE:
            name = @"RINGTONE";
            break;
        case ACTION_CANCEL:
            name = @"CANCEL";
            break;
        case ACTION_SEND_YOUTUBE_LINK:
            name = @"YOUTUBE_LINK";
            break;
	}
    
    return name;
}

-(void) performAction:(NSUInteger)theAction {
	action = theAction;
	
	switch (action) {
		case ACTION_UPLOAD_TO_YOUTUBE:
		case ACTION_UPLOAD_TO_FACEBOOK:
			if (![self gotInternet]) {
				ShareAlert(NSLocalizedString(@"upload alert title",@"Upload Movie"), NSLocalizedString(@"upload alert message",@"We're trying hard, but there's no Internet connection"));
				action = ACTION_CANCEL;
				return;
			} break;
	}
	
	switch (action)
	{
		case ACTION_UPLOAD_TO_YOUTUBE: {
			state = STATE_SELECTED;
            
            youTubeUploader.username = @"gogoscrazyholidays";
            youTubeUploader.password = @"ppithebox1";
            
			YouTubeUploadViewController *controller = [[YouTubeUploadViewController alloc] initWithNibName:@"YouTubeUploadViewController" bundle:nil];
			[controller setDelegate:self];
			[controller setBDelayedUpload:YES];
			[parentViewController presentModalViewController:controller animated:YES];
			controller.uploader = youTubeUploader;
			controller.videoTitle = NSLocalizedString(@"YT title",@"xmas musical card"); // [[self getDisplayName] uppercaseString];
			//controller.additionalText = kMilgromURL;
			controller.descriptionView.text = NSLocalizedString(@"YT desc",@"this video created with this iphone app\nvisit lofipeople at http://www.lofipeople.com");
			controller.videoPath = [[self getVideoPath] stringByAppendingPathExtension:@"mov"];
			
			[controller release];
			

		}	break;
			
		case ACTION_UPLOAD_TO_FACEBOOK: {
			state = STATE_SELECTED;
			[facebookUploader login];
			FacebookUploadViewController * controller = [[FacebookUploadViewController alloc] initWithNibName:@"FacebookUploadViewController" bundle:nil];
			[controller setDelegate:self];
			[controller setBDelayedUpload:YES];
			[parentViewController presentModalViewController:controller animated:YES];
			controller.uploader = facebookUploader;
			controller.videoTitle = NSLocalizedString(@"FB title",@"shana tova musical card") ; //[NSString stringWithFormat:@"%@",[[self getDisplayName] uppercaseString]];
			//controller.additionalText = kMilgromURL;
			controller.descriptionView.text = NSLocalizedString(@"FB desc",@"shana tova");
			controller.videoPath = [[self getVideoPath]  stringByAppendingPathExtension:@"mov" ];
			[controller release];
			
		}	break;
			
		case ACTION_SEND_VIA_MAIL:
		case ACTION_SEND_RINGTONE:
			state = STATE_SELECTED;
			break;
			
		case ACTION_ADD_TO_LIBRARY:
			state = STATE_DONE;
			break;

			
			
//		case ACTION_PLAY:
//			[appDelegate playURL:[NSURL fileURLWithPath:[[self getVideoPath] stringByAppendingPathExtension:@"mov"]]];
//			break;
			
		case ACTION_CANCEL:
			state = STATE_CANCELED;
			break;
//		case ACTION_RENDER:
//			//[appDelegate mainViewController].view.userInteractionEnabled = YES; 
//			break;
			
	}	
	
	
#ifdef _FLURRY
    [FlurryAnalytics logEvent:@"SHARE_MENU" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getCurrentActionName],@"TARGET",[(SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate] getCurrentCardTag],@"CARD",nil]];
    
#endif
	
	
	//[self.parentViewController dismissModalViewControllerAnimated:action==ACTION_CANCEL];
	

		
	if ([self audioRendered]) {
		[self proceedWithAudio];
	}
				 
//	if (bNeedToRender) {
//		RKLog(@"NeedToRender");
//		if (self.renderViewController == nil) {
//			renderViewController = [[RenderViewController alloc] initWithNibName:@"RenderViewController" bundle:nil];
//			renderViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//			[renderViewController setDelegate:self];
//		}
//		
//		[parentViewController presentModalViewController:renderViewController animated:YES];
//		
//	}
}




- (void) proceedWithAudio {
	
	switch (state) {
		case STATE_IDLE:
			break;
		case STATE_SELECTED:
		case STATE_DONE:
			switch (action) {
				case ACTION_UPLOAD_TO_YOUTUBE:
				case ACTION_UPLOAD_TO_FACEBOOK:
				case ACTION_ADD_TO_LIBRARY:
				case ACTION_SEND_VIA_MAIL:
					if (self.videoRendered ) {
							[self proceedWithVideo];
					} else {
						[self.renderManager renderVideo];
					}
					
					break;
				case ACTION_SEND_RINGTONE:
					if (self.ringtoneExported ) {
						[self sendRingtone];
					} else {
						[self.renderManager exportRingtone];
					}
					
					break;
					
				default:
					break;
			}
			
			break;
		case STATE_CANCELED:
			((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->setSongState(SONG_IDLE);
			((SingingCardAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->soundStreamStart();
			break;
	
	}
}

- (void)proceedWithVideo {
	switch (state) {
		case STATE_DONE:
			switch (action) {
									
				case ACTION_UPLOAD_TO_YOUTUBE:
					[youTubeUploader upload];
					break;
					
				case ACTION_UPLOAD_TO_FACEBOOK:
					[facebookUploader upload];
					break;
					
				case ACTION_ADD_TO_LIBRARY:
					[self exportToLibrary];
					break;
					
				
					
				default:
					break;
			}
			break;
		case STATE_SELECTED:
			switch (action) {
				case ACTION_SEND_VIA_MAIL: {
					NSString *subject = NSLocalizedString(@"email subject",@"check out my song");
					NSString *message = NSLocalizedString(@"email message",@"Isn't  it a work of art?<br/><br/><a href='http://www.lofipeople.com/shanatova/appstore'>visit lofipeople</a>");
					NSData *myData = [NSData dataWithContentsOfFile:[[self getVideoPath]  stringByAppendingPathExtension:@"mov"]];
					[self sendViaMailWithSubject:subject withMessage:message withData:myData withMimeType:@"video/mov" 
									withFileName:[[self getExoprtFileame] stringByAppendingPathExtension:@"mov"]];
					
				} break;
				default:
					break;
			}
			break;
		default:
			break;
	}
}

-(void) sendRingtone {
	NSString *subject = NSLocalizedString(@"ringtone subject",@"Sweeeet! My New Rosh Hashana Ringtone!");
	NSString *message = NSLocalizedString(@"ringtone message",@"Hey,<br/>I just made a ringtone created with the help of this cool app.<br/>Double click the attachment to listen to it first.<br/>Then, save it to your desktop, and then drag it to your itunes library. Now sync your iDevice.<br/>Next, in your iDevice, go to Settings > Sounds > Ringtone > and under 'Custom' you should see this file name.<br/>You can always switch it back if you feel like you're not ready for this work of art, yet.<br/><br/>Now, pay a visit to <a href='http://www.lofipeople.com/shanatova/appstore'>lofipeople's</a> website. I leave it to you to handle the truth.");
	
	
	NSData *myData = [NSData dataWithContentsOfFile:[[self getVideoPath]  stringByAppendingPathExtension:@"m4r"]];
	[self sendViaMailWithSubject:subject withMessage:message withData:myData withMimeType:@"audio/m4r" 
					withFileName:[[self getExoprtFileame] stringByAppendingPathExtension:@"m4r"]];	
}

#pragma mark render delegates


- (void) renderManagerRenderCanceled:(RenderManager *)manager {
	RKLog(@"renderManagerRenderCanceled");
//	[parentViewController dismissModalViewControllerAnimated:YES];
	
	

}

- (void) renderManagerVideoRendered:(RenderManager *)manager {
	RKLog(@"renderManagerVideoRendered");
	[self setVideoRendered];
//	[parentViewController dismissModalViewControllerAnimated:NO];
	
	[self proceedWithVideo];
	
}


- (void) renderManagerRingtoneExported:(RenderManager *)manager {
	RKLog(@"renderManagerRingtoneExported");
	[self setRingtoneExported];
	
	[self sendRingtone];
//	[parentViewController dismissModalViewControllerAnimated:NO];
	
}

- (void) renderManagerProgress:(float)progress {
	RKLog(@"renderManagerProgress: %f",progress);
//	[(MainViewController *)[(SingingCardAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}



- (void) YouTubeUploadViewControllerCancel:(YouTubeUploadViewController *)controller {
	RKLog(@"YouTubeUploadViewControllerCancel");
	[parentViewController dismissModalViewControllerAnimated:YES];
	state = STATE_CANCELED;
}

- (void) YouTubeUploadViewControllerUpload:(YouTubeUploadViewController *)controller {
	[parentViewController dismissModalViewControllerAnimated:YES];
	state = STATE_DONE;
	if (self.videoRendered ) {
		 [self proceedWithVideo];
	}
}

#pragma mark facebook view controller delegates

- (void) FacebookUploadViewControllerCancel:(FacebookUploadViewController *)controller {
	RKLog(@"FacebookUploadViewControllerCancel");
	[parentViewController dismissModalViewControllerAnimated:YES];
	state = STATE_CANCELED;
}

- (void) FacebookUploadViewControllerUpload:(FacebookUploadViewController *)controller {
	RKLog(@"FacebookUploadViewControllerUpload");
	[parentViewController dismissModalViewControllerAnimated:YES];
	state = STATE_DONE;
	if (self.videoRendered ) {
		[self proceedWithVideo];
	}
}

- (void)exportToLibrary
{
	RKLog(@"exportToLibrary");
	NSURL *outputURL = [NSURL fileURLWithPath:[[self getVideoPath] stringByAppendingPathExtension:@"mov"]];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
		[library writeVideoAtPathToSavedPhotosAlbum:outputURL
									completionBlock:^(NSURL *assetURL, NSError *error){
										dispatch_async(dispatch_get_main_queue(), ^{
											if (error) {
												RKLog(@"writeVideoToAssestsLibrary failed: %@", error);
												ShareAlert([error localizedDescription], [error localizedRecoverySuggestion]);
												
											}
											else {
												RKLog(@"writeVideoToAssestsLibrary successed");
												ShareAlert(NSLocalizedString(@"library alert title",@"Library"),NSLocalizedString(@"library alert message",@"The video has been saved to your photos library"));
#ifdef _FLURRY
                                                [FlurryAnalytics logEvent:@"SHARE_DONE" withParameters:[NSDictionary dictionaryWithObject:[self getCurrentActionName] forKey:@"TARGET"]];
#endif
											}
										});
										
									}];
	}
	[library release];
}

- (void)applicationDidEnterBackground {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	
//	if (sheet) {
//		[sheet dismissWithClickedButtonIndex:0 animated:NO];
//		self.sheet = nil;
//	}
	
	[renderManager applicationDidEnterBackground];
	[facebookUploader applicationDidEnterBackground];
	
}


@end

//
//  YouTubeUploader.m
//  YouTubeUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploader.h"

//#import "GData.h"
#import "GDataYouTubeConstants.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataEntryYouTubeUpload.h"
#import "GDataEntryYouTubeVideo.h"
#import "RKUBackgroundTask.h"

NSString* const kDeveloperKey = @"AI39si435pYVfbsWYr6_f70JFUWGyfK7_SEb7vOkGO7ay_ouUT6HFwaWn1GQxuyAIK-zvoeFB-GU_cqx30q-0HggREKxXG-b8w";


@interface YouTubeUploader (PrivateMethods) 

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;
- (GDataServiceGoogleYouTube *)youTubeService;
@end



@implementation YouTubeUploader

@synthesize delegates;
@synthesize videoTitle;
@synthesize videoDescription;
@synthesize videoPath;
@synthesize username;
@synthesize password;
@synthesize progress;
@synthesize link;
@synthesize task;


+ (YouTubeUploader *) youTubeUploader {
	return [[[YouTubeUploader alloc] init] autorelease];
}

- (id)init {
	
	if (self = [super init]) {
		self.delegates = [NSMutableArray array];
		_state = YOUTUBE_UPLOADER_STATE_IDLE;
	}
	return self;
}

-(void)addDelegate:(id<YouTubeUploaderDelegate>)delegate {
	[delegates addObject:delegate];
}

- (void) dealloc {
	[mUploadTicket release];
	
	[username release];
	[password release];
	[super dealloc];
}


- (NSInteger) state {
	return _state;
}

- (void) setState:(NSInteger)newState {
	
	BOOL finishUploading = _state == YOUTUBE_UPLOADER_STATE_UPLOADING;
	
	_state = newState;
	
	NSLog(@"YouTubeUploader state changed: %i",_state);
	
	if (newState == YOUTUBE_UPLOADER_STATE_UPLOADING) {
		self.task = [RKUBackgroundTask backgroundTask];
	}
	
	if (finishUploading) {
		if (newState == YOUTUBE_UPLOADER_STATE_UPLOADING) {
			NSLog(@"YouTubeUploader: YOUTUBE_UPLOADER_STATE_UPLOADING twice");
		} 
		
		if ([RKUBackgroundTask isBackground]) {
			
			NSLog(@"YouTubeUploader: finish uploading in background, no delegate");
		}
		
		[task finish];
		
		self.task = 0;
		
	}
	
	for (id<YouTubeUploaderDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(youTubeUploaderStateChanged:)]) {
			[delegate youTubeUploaderStateChanged:self];
		}
	}
	
}

#pragma mark -

- (GDataServiceGoogleYouTube *)youTubeService { 
	
	static GDataServiceGoogleYouTube* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleYouTube alloc] init];
		
//		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		[service setIsServiceRetryEnabled:YES];
	}
	
	// update the username/password each time the service is requested
	
	
	if ([username length] > 0 && [password length] > 0) {
		[service setUserCredentialsWithUsername:username
									   password:password];
	} else {
		// fetch unauthenticated
		[service setUserCredentialsWithUsername:nil
									   password:nil];
		
		self.state = YOUTUBE_UPLOADER_STATE_INCORRECT_CREDENTIALS;
		
		return nil;
		
		
	}
	
	[service setYouTubeDeveloperKey:kDeveloperKey];
	
	return service;
}

- (GDataServiceTicket *)uploadTicket {
	return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
	[mUploadTicket release];
	mUploadTicket = [ticket retain];
}

	
- (void) upload {
	
	if (self.state == YOUTUBE_UPLOADER_STATE_UPLOAD_REQUESTED || self.state == YOUTUBE_UPLOADER_STATE_UPLOADING) {
		return;
	}
	
	GDataServiceGoogleYouTube *service = [self youTubeService];
	
	if (!service) {
		return;
	}
	
	[service setYouTubeDeveloperKey:kDeveloperKey];
	
	self.state = YOUTUBE_UPLOADER_STATE_UPLOAD_REQUESTED;
	
	NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:username];
	
	
	
	
	
	NSData *data = [NSData dataWithContentsOfFile:videoPath];
	NSString *filename = [videoPath lastPathComponent];
	
	// gather all the metadata needed for the mediaGroup
	GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:videoTitle];
	
	NSString *categoryStr = @"Film";//[[mCategoryPopup selectedItem] representedObject];
	GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr]; 
	[category setScheme:kGDataSchemeYouTubeCategory];
	
	
	GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:videoDescription];
	
	//	NSString *keywordsStr = nil;//[mKeywordsField stringValue];
	//	GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
	
	BOOL isPrivate = NO;//([mPrivateCheckbox state] == NSOnState);
	
	GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
	[mediaGroup setMediaTitle:title];
	[mediaGroup setMediaDescription:desc];
	[mediaGroup addMediaCategory:category];
	//[mediaGroup setMediaKeywords:keywords];
	[mediaGroup setIsPrivate:isPrivate];
	
	NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:videoPath defaultMIMEType:@"video/quicktime"];
	
	// create the upload entry with the mediaGroup and the file data
	GDataEntryYouTubeUpload *entry;
	entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
														  data:data
													  MIMEType:mimeType
														  slug:filename];
	
	SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
	[service setServiceUploadProgressSelector:progressSel];
	
	
	GDataServiceTicket *ticket;
	ticket = [service fetchEntryByInsertingEntry:entry
									  forFeedURL:url
										delegate:self
							   didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
	
	[self setUploadTicket:ticket];
	
	
	
		
		//[self updateUI];
}

- (void) uploadVideoWithTitle:(NSString *)title withDescription:(NSString *)description andPath:(NSString *)path {
	
	self.videoTitle = title;
	self.videoDescription = description;
	self.videoPath = path;
	
	[self upload];	
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
ofTotalByteCount:(unsigned long long)dataLength {
	
	if (self.state==YOUTUBE_UPLOADER_STATE_UPLOAD_REQUESTED) {
		self.state = YOUTUBE_UPLOADER_STATE_UPLOADING;
	}
	
	[task update];
	
	progress = (float)numberOfBytesRead/(float)dataLength;
	NSLog(@"youtube upload progress: %f",progress);
	
	for (id<YouTubeUploaderDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(youTubeUploaderProgress:)]) {
			[delegate youTubeUploaderProgress:progress];
		}
	}
	
	
}

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry error:(NSError *)error {
	
	[self setUploadTicket:nil];
		
	if (error == nil) {
		GDataLink *videoLink = [videoEntry HTMLLink];
		link = [videoLink URL];
		//NSLog(@"location: %@",[videoEntry location]);
		
		self.state = YOUTUBE_UPLOADER_STATE_UPLOAD_FINISHED;
		
	} else {
//		NSBeginAlertSheet(@"Upload failed", nil, nil, nil,
//						  [self window], nil, nil,
//						  nil, nil, @"Upload failed: %@", error);
		
		switch (self.state) {
			case YOUTUBE_UPLOADER_STATE_UPLOAD_REQUESTED:
				self.state = YOUTUBE_UPLOADER_STATE_INCORRECT_CREDENTIALS;
				break;
			case YOUTUBE_UPLOADER_STATE_UPLOADING:
				self.state = YOUTUBE_UPLOADER_STATE_UPLOAD_STOPPED;
				break;
				
			default:
				break;
		}
		
	}
	
}

@end

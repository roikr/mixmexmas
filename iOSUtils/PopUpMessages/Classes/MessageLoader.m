//
//  MessageLoader.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageLoader.h"
#import "URLCacheAlert.h"


@interface MessageLoader(PrivateMethods) 

@end


@implementation MessageLoader

@synthesize delegate,xmlData,isModified,lastModified,connection;


+(MessageLoader *)messageLoader:(NSURL *)theURL modified:(NSString *)modified delegate:(id<MessageLoaderDelegate>) theDelegate {
    
    MessageLoader *loader = [[[MessageLoader alloc] init ] autorelease];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    
 //   [theRequest addValue:modified forHTTPHeaderField:@"If-Modified-Since"];
    
    loader.connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:loader];
    loader.isModified = NO;
    loader.delegate = theDelegate;
    
    if (loader.connection == nil) {
        /* inform the user that the connection failed */
        NSString *message = NSLocalizedString (@"Unable to initiate request.",
                                               @"NSURLConnection initialization method failed.");
        URLCacheAlertWithMessage(message);
    }
    
    return loader;
    

//    
//    /* default date if file doesn't exist (not an error) */
//	NSDate *fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
//    
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//		/* retrieve file attributes */
//        NSError *error;
//		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
//		if (attributes != nil) {
//			fileDate = [attributes fileModificationDate];
//		}
//		else {
//			URLCacheAlertWithError(error);
//		}
//	}
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    
//    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
//    
//    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [theRequest addValue:[dateFormatter stringFromDate:fileDate]  forHTTPHeaderField:@"If-Modified-Since"];
//	[dateFormatter release];
    
    
    //    [request setHTTPMethod:@"POST"];
    
    
    
    
    // create the connection with the request and start loading the data
    
    
    //    self.connection = nil;

    
    
    
}


- (void)dealloc
{
	self.xmlData = nil;
	[super dealloc];
}


#pragma mark NSURLConnection delegate methods

/*
 Disable caching so that each time we run this app we are starting with a clean slate. You may not want to do this in your application.
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
/* this application does not use a NSURLCache disk or memory cache */
    return nil;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* This method is called when the server has determined that it has
	 enough information to create the NSURLResponse. It can be called
	 multiple times, for example in the case of a redirect, so each time
	 we reset the data capacity. */
    
	/* create the NSMutableData instance that will hold the received data */
    
	long long contentLength = [response expectedContentLength];
	if (contentLength == NSURLResponseUnknownLength) {
		contentLength = 500000;
	}
    
    self.xmlData = [NSMutableData dataWithCapacity:(NSUInteger)contentLength];

    
	/* Try to retrieve last modified date from HTTP header. If found, format
	 date so it matches format of cached image file modification date. */
    
	if ([response isKindOfClass:[NSHTTPURLResponse self]]) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        switch (statusCode) {
            case 304:
                NSLog(@"304 Not Modified");
                break;
                
            case 200:
                NSLog(@"200 OK");
                isModified = YES;
                NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
                self.lastModified = [headers objectForKey:@"Last-Modified"];
                if (self.lastModified == nil) {
                    /* default if last modified date doesn't exist (not an error) */
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    
                    /* avoid problem if the user's locale is incompatible with HTTP-style dates */
                    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
                    
                    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
                    self.lastModified = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                    [dateFormatter release];
                }
                NSLog(@"%@",self.lastModified);
                break;
            default:
                break;
        }
        
        
		
	}
}


// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the downloaded chunk of data.
    [xmlData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.connection = nil;
    self.lastModified = nil;
    self.xmlData = nil;
    URLCacheAlertWithError(error);
	[self.delegate messageLoaderDidFailed:self];
}



- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    self.lastModified = nil;
    [self.delegate messageLoaderDidFinished:self];
}

@end

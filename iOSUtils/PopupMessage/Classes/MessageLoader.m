//
//  MessageLoader.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageLoader.h"
#ifdef _RK_DEBUG
    #import "URLCacheAlert.h"
#endif

@interface MessageLoader(PrivateMethods) 

@end


@implementation MessageLoader

@synthesize delegate,xmlData,lastModified,connection,statusCode;


+(MessageLoader *)messageLoader:(NSURL *)theURL modified:(NSString *)modified delegate:(id<MessageLoaderDelegate>) theDelegate {
    NSLog(@"messageLoader: %@, modified: %@",[theURL path],modified);
    MessageLoader *loader = [[[MessageLoader alloc] init ] autorelease];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    
    if (modified!=nil) {
         [theRequest addValue:modified forHTTPHeaderField:@"If-Modified-Since"];
    }
   
    
    loader.connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:loader];
    loader.statusCode = 0;
    loader.delegate = theDelegate;
    
    if (loader.connection == nil) {
        /* inform the user that the connection failed */
#ifdef _RK_DEBUG
        NSString *message = NSLocalizedString (@"Unable to initiate request.",
                                               @"NSURLConnection initialization method failed.");

        URLCacheAlertWithMessage(message);
#endif
    }
    
    return loader;
    

    
    
    
}


- (void)dealloc
{
    [lastModified release];
	[xmlData release];
    [connection release];
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
        statusCode = [(NSHTTPURLResponse*)response statusCode];
        switch (statusCode) {
            case 304:
                NSLog(@"304 Not Modified");
                break;
                
            case 200:
                NSLog(@"200 OK");
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
                NSLog(@"lastModified: %@",self.lastModified);
                break;
            case 404:
                NSLog(@"404 Not Found");
                break;
            default:
                NSLog(@"other: %i",statusCode);
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
#ifdef _RK_DEBUG	
    URLCacheAlertWithError(error);
#endif
    
	[self.delegate messageLoaderDidFailed:self];
}



- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
   
    
    [self.delegate messageLoaderDidFinished:self];
}

@end

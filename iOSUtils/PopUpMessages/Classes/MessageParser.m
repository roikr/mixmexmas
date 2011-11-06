//
//  MessageParser.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageParser.h"
#import "URLCacheAlert.h"

/* cache update interval in seconds */
const double URLCacheInterval = 86400.0;

@interface MessageParser(PrivateMethods) 

- (void) initCache;
- (void) clearCache;
- (void) getFileModificationDate;

-(void) parse;

@end

@implementation MessageParser

@synthesize delegate,currentString,alertView,links,connection,dataPath,filePath,fileDate;

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

+(MessageParser *)messageParser  {
    MessageParser *parser = [[[MessageParser alloc] init ] autorelease];
    
    /* By default, the Cocoa URL loading system uses a small shared memory cache.
	 We don't need this cache, so we set it to zero when the application launches. */
    
    /* turn off the NSURLCache shared cache */
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
    
    /* prepare to use our own on-disk cache */
	[parser initCache];
       
    return parser;
}

- (void)downloadAndParse:(NSURL *)theURL{
    
    /* get the path to the cached image */
    
	[filePath release]; /* release previous instance */
	NSString *fileName = [[theURL path] lastPathComponent];
	filePath = [[dataPath stringByAppendingPathComponent:fileName] retain];
    
	/* apply daily time interval policy */
    
	/* In this program, "update" means to check the last modified date
	 of the image to see if we need to load a new version. */
    
	[self getFileModificationDate];
	/* get the elapsed time since last file update */
	NSTimeInterval time = fabs([fileDate timeIntervalSinceNow]);
	if (time > URLCacheInterval) {
		/* file doesn't exist or hasn't been updated for at least one day */
		
		self.connection = [[URLCacheConnection alloc] initWithURL:theURL delegate:self];
	}
	else {
        [self parse];
	}

    

    
    
}

-(void) parse {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
    parser.delegate = self;
    self.currentString = [NSMutableString string];
    
    [parser parse];
    
    [parser release];
    
    [delegate MessageParserDelegateParsed:self];
    self.currentString = nil;

}



- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"];
    
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		return;
	}
    
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
}


/* removes every file in the cache directory */

- (void) clearCache
{
	/* remove the cache directory and its contents */
	if (![[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
    
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
    
}


/* get modification date of the current cached image */

- (void) getFileModificationDate
{
	/* default date if file doesn't exist (not an error) */
	self.fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		/* retrieve file attributes */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		if (attributes != nil) {
			self.fileDate = [attributes fileModificationDate];
		}
		else {
			URLCacheAlertWithError(error);
		}
	}
}


/*
 ------------------------------------------------------------------------
 URLCacheConnectionDelegate protocol methods
 ------------------------------------------------------------------------
 */

#pragma mark -
#pragma mark URLCacheConnectionDelegate methods

- (void) connectionDidFail:(URLCacheConnection *)theConnection
{
}


- (void) connectionDidFinish:(URLCacheConnection *)theConnection
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        
		/* apply the modified date policy */
        
		[self getFileModificationDate];
		NSComparisonResult result = [theConnection.lastModified compare:fileDate];
		if (result == NSOrderedDescending) {
			/* file is outdated, so remove it */
			if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
				URLCacheAlertWithError(error);
			}
            
		}
	}
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
		/* file doesn't exist, so create it */
		[[NSFileManager defaultManager] createFileAtPath:filePath
												contents:theConnection.receivedData
											  attributes:nil];
        
		
	}
	
    
	/* reset the file's modification date to indicate that the URL has been checked */
    
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
	if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:filePath error:&error]) {
		URLCacheAlertWithError(error);
	}
	[dict release];
    
	
	[self parse];
}





#pragma mark Parsing support methods


#define ELTYPE(typeName) (NSOrderedSame == [elementName caseInsensitiveCompare:@#typeName])

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    
    if (ELTYPE(message)) {
        self.alertView = [[UIAlertView alloc] init];
        self.links = [NSMutableArray array];
 //       [flights addObject:attributeDict];
    } else if (ELTYPE(title)) {
         [currentString setString:@""];
    } else if (ELTYPE(body)) {
        [currentString setString:@""];
    } else if (ELTYPE(button)) {
        [currentString setString:@""];
        NSString *link = [attributeDict valueForKey:@"link"];
        if (link == nil) {
            link=@"";
        }
      
        [links addObject:link];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (ELTYPE(message)) {
    } else if (ELTYPE(title)) {
        alertView.title = currentString;
    } else if (ELTYPE(body)) {
        alertView.message = currentString;
    } else if (ELTYPE(button)) {
        [alertView addButtonWithTitle:currentString];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [currentString appendString:string];
}

@end

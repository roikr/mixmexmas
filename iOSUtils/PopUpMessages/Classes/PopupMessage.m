//
//  PopupMessage.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PopupMessage.h"



@implementation ButtonData
@synthesize text,link,retry,pressed;

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		self.text = [coder decodeObjectForKey:@"text"];
		self.link = [coder decodeObjectForKey:@"link"];
        self.retry = [coder decodeBoolForKey:@"retry"];
        self.pressed = [coder decodeBoolForKey:@"pressed"];
		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:@"text"];
	[coder encodeObject:self.link forKey:@"link"];
    [coder encodeBool:self.retry forKey:@"retry"];
    [coder encodeBool:self.pressed forKey:@"pressed"];
}

- (void)dealloc {
    [text release];
    [link release];
    [super dealloc];
}

@end


@implementation MessageData
@synthesize title,message,buttons,version,messageID,modified;

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		self.title = [coder decodeObjectForKey:@"title"];
		self.message = [coder decodeObjectForKey:@"message"];
        self.buttons = [coder decodeObjectForKey:@"buttons"];
        self.version = [coder decodeObjectForKey:@"version"];
        self.messageID = [coder decodeObjectForKey:@"messageID"];
        self.modified = [coder decodeObjectForKey:@"modified"];
        
		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
	[coder encodeObject:self.message forKey:@"message"];
    [coder encodeObject:self.buttons forKey:@"buttons"];
    [coder encodeObject:self.version forKey:@"version"];
    [coder encodeObject:self.messageID forKey:@"messageID"];
    [coder encodeObject:self.modified forKey:@"modified"];
    
}

- (void)dealloc
{
	[title release];
    [message release];
    [buttons release];
    [version release];
    [messageID release];
    [modified release];
    [super dealloc];
}

@end

@implementation PopupMessage
@synthesize loader,parser,data,url;


+(PopupMessage*) popupMessage:(NSURL *)theURL {
    
    
    PopupMessage* message = [[[PopupMessage alloc] init] autorelease];
    
    message.url = theURL;
    
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [libraryPath stringByAppendingPathComponent:[[theURL path] lastPathComponent]];
    
    message.data = (MessageData *)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    message.loader = [MessageLoader messageLoader:theURL modified:message.data.modified delegate:message];
    
    return message;
}

-(BOOL) shouldRetry {
    for (ButtonData *button in data.buttons) {
        if (button.retry || !button.pressed) {
            return YES;
        }
    }
    return NO;
}

-(void)messageLoaderDidFinished:(MessageLoader *)theLoader {
    NSLog(@"messageLoaderDidFinished: %@",[[NSString alloc] initWithData:theLoader.xmlData encoding:NSASCIIStringEncoding]);
    
    if ([theLoader isModified]) {
        NSLog(@"message modified");
        //if ([self shouldRetry]) {
        self.parser = [MessageParser messageParser:theLoader.xmlData delegate:self];
        //}
        
    }
    self.loader = nil;
    
}

-(void)messageLoaderDidFailed:(MessageLoader *)theLoader {
    NSLog(@"messageLoaderDidFailed: %@",[[NSString alloc] initWithData:theLoader.xmlData encoding:NSASCIIStringEncoding]);
    self.loader = nil;
}

-(void)messageParserDidFinish:(MessageParser *)theParser {
    self.data = nil;
    self.data = theParser.message;
    
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [libraryPath stringByAppendingPathComponent:[[self.url path] lastPathComponent]];
    BOOL res = [NSKeyedArchiver archiveRootObject:self.data toFile:filePath];
    NSLog(@"archive: %i",res);
}


@end

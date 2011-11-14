//
//  PopupMessage.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PopupMessage.h"



@implementation ButtonData
@synthesize text,link,retry; //,pressed;

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		self.text = [coder decodeObjectForKey:@"text"];
		self.link = [coder decodeObjectForKey:@"link"];
        self.retry = [coder decodeBoolForKey:@"retry"];
//        self.pressed = [coder decodeBoolForKey:@"pressed"];
		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:@"text"];
	[coder encodeObject:self.link forKey:@"link"];
    [coder encodeBool:self.retry forKey:@"retry"];
//    [coder encodeBool:self.pressed forKey:@"pressed"];
}

- (void)dealloc {
    [text release];
    [link release];
    [super dealloc];
}

@end


@implementation MessageData
@synthesize title,message,buttons,appVersion,messageID,modified,displayed,retry;

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		self.title = [coder decodeObjectForKey:@"title"];
		self.message = [coder decodeObjectForKey:@"message"];
        self.buttons = [coder decodeObjectForKey:@"buttons"];
        self.appVersion = [coder decodeObjectForKey:@"appVersion"];
        self.messageID = [coder decodeObjectForKey:@"messageID"];
        self.modified = [coder decodeObjectForKey:@"modified"];
        self.displayed = [coder decodeBoolForKey:@"displayed"];
        self.retry = [coder decodeBoolForKey:@"retry"];
        
		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
	[coder encodeObject:self.message forKey:@"message"];
    [coder encodeObject:self.buttons forKey:@"buttons"];
    [coder encodeObject:self.appVersion forKey:@"appVersion"];
    [coder encodeObject:self.messageID forKey:@"messageID"];
    [coder encodeObject:self.modified forKey:@"modified"];
    [coder encodeBool:self.displayed forKey:@"displayed"];
    [coder encodeBool:self.retry forKey:@"retry"];
}



- (void)dealloc
{
	[title release];
    [message release];
    [buttons release];
    [appVersion release];
    [messageID release];
    [modified release];
    [super dealloc];
}

@end

@interface PopupMessage(PrivateMethods) 
-(void) archive;
-(void) popup;
@end

@implementation PopupMessage
@synthesize loader,parser,data,url;


+(PopupMessage*) popupMessage:(NSString *)theURL {
    
    
    PopupMessage* message = [[[PopupMessage alloc] init] autorelease];
    
    message.url = [NSURL URLWithString:[theURL stringByAppendingFormat:@"_%@.xml",[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]]];
                                       
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [libraryPath stringByAppendingPathComponent:[[message.url path] lastPathComponent]];
    
    message.data = (MessageData *)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    message.loader = [MessageLoader messageLoader:message.url modified:message.data.modified delegate:message];
    
    return message;
}

- (void)dealloc
{
    [loader release];
	[parser release];
    [data release];
    [url release];
    [super dealloc];
}

-(void) archive {
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [libraryPath stringByAppendingPathComponent:[[self.url path] lastPathComponent]];
    BOOL res = [NSKeyedArchiver archiveRootObject:self.data toFile:filePath];
    NSLog(@"archive: %i",res);
}


-(void) popup {
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSLog(@"appVersion: %@, currentVersion: %@",data.appVersion,versionString);
    
    if (data!=nil && (data.appVersion == nil || ![data.appVersion isEqualToString:versionString]) && (!data.displayed || data.retry) ) {
        UIAlertView *view = [[UIAlertView alloc] init];
        [view setDelegate:self];
        [view setTitle:data.title];
        [view setMessage:data.message];
        
        
        for (ButtonData *button in data.buttons) {
            [view addButtonWithTitle:button.text];
        }
        [view show];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView: %i",buttonIndex);
    
   
    data.displayed = YES;
    ButtonData *button = [self.data.buttons objectAtIndex:buttonIndex];
    data.retry = button.retry;
    
    [self archive];
    
    if (button.link) {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:button.link]]) {
            
            NSLog(@"Failed to open url: %@",button.link);
        }
    }
}

-(void)messageLoaderDidFinished:(MessageLoader *)theLoader {
    NSLog(@"messageLoaderDidFinished: %@",[[NSString alloc] initWithData:theLoader.xmlData encoding:NSASCIIStringEncoding]);
    
    if ([theLoader isMessageModified]) {
        self.parser = [MessageParser messageParser:theLoader.xmlData delegate:self];
    } else {
        [self popup];
    }
    
    
}

-(void)messageLoaderDidFailed:(MessageLoader *)theLoader {
    NSLog(@"messageLoaderDidFailed: %@",[[NSString alloc] initWithData:theLoader.xmlData encoding:NSASCIIStringEncoding]);
   
    [self popup];
}

-(void)messageParserDidFinish:(MessageParser *)theParser {
    
    if (self.data!=nil) {
        NSLog(@"displayed:%i, retry: %i",self.data.displayed,self.data.retry);
        NSLog(@"old messageID: %@", self.data.messageID );
    }
    
    NSLog(@"new messageID: %@", theParser.message.messageID );
   
   
    if (self.data==nil || self.data.messageID==nil || [self.data.messageID compare:theParser.message.messageID options:NSNumericSearch] == NSOrderedAscending || data.retry) {
        self.data = theParser.message;
        self.data.modified = self.loader.lastModified;
        [self archive];
    } 
    
       
    [self popup];
}




@end

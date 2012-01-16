//
//  PopupMessage.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PopupMessage.h"
#include "ofxiPhoneExtras.h"


@interface PopupMessage(PrivateMethods) 
-(void) setTimer;
-(void) popup;
@end

@implementation PopupMessage
@synthesize url,loader,timer,view;


+(PopupMessage*) popupMessage:(NSString *)theURL {
    
    
    PopupMessage* message = [[[PopupMessage alloc] init] autorelease];
    
    NSString *preferredLocalizations = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    message.url = [theURL stringByAppendingFormat:@"/messages/%@/timeline_%@.xml",preferredLocalizations,versionString];
    
    
    return message;
}

- (void)dealloc
{
    
    [loader release];
    [url release];
    [super dealloc];
}

-(void) load {
    
   
    //NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    
    NSDate *lastModified = nil;
    NSError *error = nil;	
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[url lastPathComponent]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        if (dict) {
            lastModified = [dict fileModificationDate];
        }
    }

    self.loader = [MessageLoader messageLoader:[NSURL URLWithString:url] lastModified:lastModified delegate:self];
    

}

-(void) unload {
    if (view) {
        [view dismissWithClickedButtonIndex:-1 animated:NO];
    } 
    
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    } 
  
}


-(void) setTimer {
    if (messages.getIsValid()) {
        message &m = messages.getMessage();
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:m.time target:self selector:@selector(popup) userInfo:nil repeats:NO];
    }
}


-(void) popup {
   
    
    message &m = messages.getMessage();
    
    self.view = [[UIAlertView alloc] init];
    [view setDelegate:self];
    [view setTitle:ofxStringToNSString(m.title)];
    [view setMessage:ofxStringToNSString(m.body)];
    
    for (vector<button>::iterator iter=m.buttons.begin();iter!=m.buttons.end();iter++) {
        [view addButtonWithTitle:ofxStringToNSString(iter->text)];
    }
    
    [view show];
    [view release];
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex>=0) {
        NSLog(@"alertView: %i",buttonIndex);
        
        message &m = messages.getMessage();
        
        string link = m.buttons[buttonIndex].link;
        bool bDone = !link.empty(); // if link pressed the message is done !
        
        messages.nextMessage(bDone); 
        
        [self setTimer];
        
        if (!link.empty()) {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:ofxStringToNSString(link)]]) {
                
                NSLog(@"Failed to open url: %@",ofxStringToNSString(link));
            }
        }    
    }
    self.view = nil;
}    
    


-(void)messageLoaderDidFinished:(MessageLoader *)theLoader {
    NSLog(@"messageLoaderDidFinished: %@",[[NSString alloc] initWithData:theLoader.xmlData encoding:NSASCIIStringEncoding]);
    
    switch ([theLoader statusCode]) {
        case 0:
            break;
        case 200: // OK - Message Is Modified
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:theLoader.lastModified forKey:NSFileModificationDate];
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[url lastPathComponent]];
           [[NSFileManager defaultManager] createFileAtPath:filePath contents:theLoader.xmlData attributes:dict];
            
            
            messages.loadMessages(ofxNSStringToString([url lastPathComponent]),true);
            [self setTimer];

        }   break;
        case 304: // Not Modified
             messages.loadMessages(ofxNSStringToString([url lastPathComponent]));
            [self setTimer];
            
            break;
        case 404: // Not Modified - don't popup
            break;
        default:
            break;
    }

    
        
    
}

-(void)messageLoaderDidFailed:(MessageLoader *)theLoader {
    NSLog(@"messageLoaderDidFailed: %@",[[NSString alloc] initWithData:theLoader.xmlData encoding:NSASCIIStringEncoding]);
   
//    [self popup];
}



@end

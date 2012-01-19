//
//  PopupMessage.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PopupMessage.h"
#include "ofxiPhoneExtras.h"
#include "ofxPopupMessages.h"

@interface PopupMessage(PrivateMethods) 
@end

@implementation PopupMessage
@synthesize url,loader,view,timer,messageDisplayed,delegate;


+(PopupMessage*) popupMessage:(NSString *)theURL {
    
    return [[[PopupMessage alloc] initWithURL:theURL] autorelease];
}

-(id) initWithURL:(NSString *)theURL {
    
    
    if (self=[super init]) {
        NSString *preferredLocalizations = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
        self.url = [theURL stringByAppendingFormat:@"/messages/%@/timeline_%@.xml",preferredLocalizations,versionString];
        popup.setup(ofxNSStringToString([url lastPathComponent]),ofxNSStringToString(versionString));
        messageDisplayed = NO;

    }
    
    return self;
}

- (void)dealloc
{
    
    [loader release];
    [url release];
    [super dealloc];
}

-(void) load {
    
   
//    [self messageLoaderDidFinished:nil];
//    return;
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
    
    popup.unload();
    
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    }
    
    if (view) {
        [view dismissWithClickedButtonIndex:-1 animated:NO];
    } 
    
    
  
}


-(void) popup {
    
    [timer invalidate];
    self.timer = nil;
    
    if ([delegate popupMessageShouldDisplayMessage:self]) {
        
        message m;
        
        if (startMessage) {
            m = popup.startMessage;
        } else {
            m = *(popup.citer);
        }

        
        self.view = [[UIAlertView alloc] init];
        [view setDelegate:self];
        [view setTitle:ofxStringToNSString(m.title)];
        [view setMessage:ofxStringToNSString(m.body)];
        
        for (vector<button>::iterator iter=m.buttons.begin();iter!=m.buttons.end();iter++) {
            [view addButtonWithTitle:ofxStringToNSString(iter->text)];
        }
        
        [view show];
        [view release];
    } else {
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(popup) userInfo:nil repeats:NO];
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex>=0) {
        
        
        
        NSLog(@"alertView: %i",buttonIndex);
        
        message m;
        
        if (startMessage) {
            m = popup.startMessage;
            startMessage = NO;
        } else {
            m = *(popup.citer);
        }

        
        
        
        string link = m.buttons[buttonIndex].link;
        if (!m.buttons[buttonIndex].retry) { // if no rerty message is done !
            popup.messagesDone.insert(m.messageID);
        }
        
        
        
        popup.nextMessage(); 
        if (popup.citer != popup.messages.end()) {
            self.timer =  [NSTimer scheduledTimerWithTimeInterval:popup.nextDelay target:self selector:@selector(popup) userInfo:nil repeats:NO];
        }
        

        
        if (!link.empty()) {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:ofxStringToNSString(link)]]) {
                
                NSLog(@"Failed to open url: %@",ofxStringToNSString(link));
            }
        }    
    }
    self.view = nil;
    messageDisplayed = NO;
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
        
            // if new version or file, need to delete playhead
            popup.clear();
            
           

        }  
        case 304: // Not Modified
            popup.load();
            
             startMessage = popup.bStartMessage && popup.messagesDone.find(popup.startMessage.messageID) == popup.messagesDone.end();
            if (startMessage) {
                [self popup];
            } else {
                popup.nextMessage(); 
                if (popup.citer != popup.messages.end()) {
                    self.timer =  [NSTimer scheduledTimerWithTimeInterval:popup.nextDelay target:self selector:@selector(popup) userInfo:nil repeats:NO];
                }
                
            }

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

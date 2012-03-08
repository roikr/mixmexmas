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

#ifdef _FLURRY
#import "FlurryAnalytics.h"
#endif

@interface PopupMessage(PrivateMethods) 
-(void) start;
-(void) next;
@end

@implementation PopupMessage
@synthesize url,loader,view,timer,messageDisplayed,delegate;

//#define LOCAL_TIMELINE
#define REPEAT_TIME_INTERVAL 2.0

+(PopupMessage*) popupMessage:(NSString *)theURL delegate:(id<PopupMessageDelegate>) theDelegate{
    
    return [[[PopupMessage alloc] initWithURL:theURL delegate:theDelegate] autorelease];
}

-(id) initWithURL:(NSString *)theURL delegate:(id<PopupMessageDelegate>) theDelegate{
    
    
    if (self=[super init]) {
        NSString *preferredLocalizations = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
        self.url = [theURL stringByAppendingFormat:@"/messages/%@/timeline_%@.xml",preferredLocalizations,versionString];
        popup.setup(ofxNSStringToString([url lastPathComponent]),ofxiPhoneGetDocumentsDirectory(),ofxNSStringToString(versionString));
        messageDisplayed = NO;
        self.delegate = theDelegate;

#ifdef LOCAL_TIMELINE
        NSError *error = nil;	
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [[NSFileManager defaultManager] removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"/timeline_1.0.0.xml"] error:&error];
        [[NSFileManager defaultManager] copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/timeline_1.0.0.xml"] toPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"/timeline_1.0.0.xml"] error:&error];
        
        
        
//        [[NSFileManager defaultManager] removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"/playhead_1.0.0.xml"] error:&error]; // popup.clear(); // clear playhead
//        
//        [[NSFileManager defaultManager] removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"/popups_state.xml"] error:&error]; // clear state
        
#endif

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

#ifdef LOCAL_TIMELINE
    [self start];
#else
    self.loader = [MessageLoader messageLoader:[NSURL URLWithString:url] lastModified:lastModified delegate:self];
#endif

}

-(void) unload {
    
    popup.save();
    
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    }
    
    if (view) {
        [view dismissWithClickedButtonIndex:-1 animated:NO];
    } 
    
    
  
}

-(void) start {
    popup.load();
    
    startMessage = popup.bStartMessage && popup.messagesDone.find(popup.startMessage.messageID) == popup.messagesDone.end();
    if (startMessage) {
        [self popup];
    } else {
        [self next];
        
    }
}

-(void) next {    
    popup.nextMessage(); 
    if (popup.citer != popup.messages.end()) {
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:popup.nextDelay target:self selector:@selector(popup) userInfo:nil repeats:NO];
        NSLog(@"next\tnextDelay: %f, nextMessage: %d",popup.nextDelay,distance(popup.messages.begin(), popup.citer) );
    }
    
    popup.save();
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
        
        
        [view setTitle:[NSString stringWithCString:m.title.c_str() encoding:NSUTF8StringEncoding]];
        [view setMessage:[NSString stringWithCString:m.body.c_str() encoding:NSUTF8StringEncoding]];
        
        for (vector<button>::iterator iter=m.buttons.begin();iter!=m.buttons.end();iter++) {
            [view addButtonWithTitle:[NSString stringWithCString:iter->text.c_str() encoding:NSUTF8StringEncoding]];
        }
        
        [view show];
        [view release];
    } else {
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:REPEAT_TIME_INTERVAL target:self selector:@selector(popup) userInfo:nil repeats:NO];
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    message m;
    
    if (startMessage) {
        m = popup.startMessage;
        startMessage = NO;
    } else {
        m = *(popup.citer);
    }
    
#ifdef _FLURRY
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",buttonIndex],@"BUTTON", nil];
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"POPUP_%i",m.messageID] withParameters:dictionary];
#endif
    
    if (buttonIndex>=0) {
        
//        NSLog(@"alertView: %i",buttonIndex);
        
        

        string link = m.buttons[buttonIndex].link;
        if (!m.buttons[buttonIndex].retry) { // if no rerty message is done !
            popup.messagesDone.insert(m.messageID);
        }
        
        [self next];        

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
            [self start];

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

//
//  MessageParser.m
//  PopUpMessages
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageParser.h"
#import "PopupMessage.h"


@interface MessageParser(PrivateMethods) 

@end

@implementation MessageParser

@synthesize delegate,currentString,message,currentButton;


- (void)dealloc
{
    
    [super dealloc];
}

+(MessageParser *)messageParser:(NSData*)xmlData delegate:(id<MessageParserDelegate>) theDelegate{
    MessageParser *parser = [[[MessageParser alloc] init ] autorelease];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    xmlParser.delegate = parser;
    parser.delegate = theDelegate;
    parser.currentString = [NSMutableString string];
    
    [xmlParser parse];
    
    [xmlParser release];
    
    

    return parser;
}


#pragma mark Parsing support methods


#define ELTYPE(typeName) (NSOrderedSame == [elementName caseInsensitiveCompare:@#typeName])

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    
    if (ELTYPE(message)) {
        self.message = [[[MessageData alloc] init] autorelease];
        message.buttons = [NSMutableArray array];
        message.appVersion = [attributeDict valueForKey:@"appVersion"];
        message.messageID = [attributeDict valueForKey:@"id"];
        message.displayed = NO;
        message.retry = NO;
    } else if (ELTYPE(title)) {
        self.currentString =[NSMutableString string];
    } else if (ELTYPE(body)) {
        self.currentString =[NSMutableString string];
    } else if (ELTYPE(button)) {
        self.currentString =[NSMutableString string];
        self.currentButton = [[[ButtonData alloc] init] autorelease];
        currentButton.link = [attributeDict valueForKey:@"link"];
        NSString *retry = [attributeDict valueForKey:@"retry"];
        currentButton.retry = retry ? [retry isEqualToString:@"1"] : NO;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (ELTYPE(message)) {
    } else if (ELTYPE(title)) {
        message.title = currentString;
        self.currentString = nil;
    } else if (ELTYPE(body)) {
        message.message = currentString;
        self.currentString = nil;
    } else if (ELTYPE(button)) {
        currentButton.text = currentString;
        self.currentString = nil;
        [message.buttons addObject:currentButton];
        self.currentButton = nil;
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [currentString appendString:string];
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[delegate messageParserDidFinish:self];
}


@end

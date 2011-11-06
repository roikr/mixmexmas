//
//  InfoViewController.h
//  MixMeXmas
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController {
    UIWebView *webView;
}

@property (nonatomic,retain) IBOutlet UIWebView *webView;

- (IBAction) back:(id)sender;
@end

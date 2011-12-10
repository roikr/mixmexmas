//
//  InfoViewController.h
//  MixMeXmas
//
//  Created by Roee Kremer on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController<UIWebViewDelegate> {
    UIWebView *webView;
    NSString *url;
    UIButton *restoreButton;    
    id restoreTarget;
}

@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) IBOutlet UIButton *restoreButton;
@property (nonatomic,retain) id restoreTarget;

- (IBAction) back:(id)sender;

@end

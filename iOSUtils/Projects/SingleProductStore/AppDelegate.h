//
//  AppDelegate.h
//  SingleProductStore
//
//  Created by Roee Kremer on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleProductStore.h"



@class SingleProductStore;

@interface AppDelegate : UIResponder <UIApplicationDelegate,SingleProductStoreDelegate> {
    SingleProductStore *store;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) SingleProductStore *store;

@end

//
//  RKMacros.h
//  
//
//  Created by Roee Kremer on 8/22/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#ifdef _Debug
#define _SETTINGS
#endif

#ifdef _Debug
#define RKLog( s, ... ) \
do { \
NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] ); \
} \
while (0)
#else
#define RKLog( s, ... ) do {} while (0)
#endif

//NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] ); \


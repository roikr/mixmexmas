//
//  ofxPopupMessages.h
//  emptyExample
//
//  Created by Roee Kremer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma once

#include "ofMain.h"
#include <set.h>

using namespace std;

struct button {
    string text;
    string link;
};

struct message {
    string title;
    string body;
    vector<button> buttons; 
    int messageID;
    int time;
    bool bDisplayed;
    bool bRetry;
    
};


class ofxPopupMessages{
    
public:
   
    ofxPopupMessages():bLoaded(false),citer(messages.end()) {};
    void loadMessages(string filename,bool bNew = false);
    
    
    message &getMessage();
    void nextMessage(bool bDone);
    bool getIsValid();
    
private:
    bool bLoaded;
    
    void loadState();
    void saveState();
    
    vector<message> messages;
    vector<message>::iterator citer;
    set<int> messagesDone;
};

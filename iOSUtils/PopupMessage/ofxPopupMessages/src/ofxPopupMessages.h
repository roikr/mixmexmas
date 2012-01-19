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
    bool retry;
};

struct message {
    string title;
    string body;
    vector<button> buttons; 
    int messageID;
    double time;
    bool bDisplayed;
    bool bRetry;
    
};


class ofxPopupMessages{
    
public:
   
    void setup(string filename,string version);
       
    void load();
    void unload();    

    void nextMessage();
    void clear();
    
    
    message startMessage;
    bool bStartMessage;
    
    vector<message> messages;
    vector<message>::iterator citer;
    set<int> messagesDone;

    double nextDelay;
    
            
private:
    
    string version;
    string filename;
    double startDelay;
    
    int timer;
    bool bStarted;
    
};


//messagesDone.insert(messageID);
//return messagesDone.find(messageID) != messagesDone.end();

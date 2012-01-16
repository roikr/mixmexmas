//
//  ofxPopupMessages.cpp
//  emptyExample
//
//  Created by Roee Kremer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "ofxPopupMessages.h"
#include "ofxXmlSettings.h"


void ofxPopupMessages::loadMessages(string filename,bool bNew) {
    
    if (bLoaded && !bNew) {
        return;
    }
    
    messages.clear();
    
    ofxXmlSettings xml;
    xml.loadFile(filename); // xml uses ofToDataPath
    
    xml.pushTag("timeline");
    
    for (int i=0; i<xml.getNumTags("message"); i++) {
        message m;
        m.messageID = xml.getAttribute("message", "id", 0,i);
        m.time = xml.getAttribute("message", "time", 0,i);
        
        xml.pushTag("message",i);
        m.title = xml.getValue("title", "");
        m.body = xml.getValue("body", "");
        for (int j=0; j<xml.getNumTags("button"); j++) {
            button b;
            b.link = xml.getAttribute("button", "link", "",j);
            b.text = xml.getValue("button","",j);
            m.buttons.push_back(b);
        }
        xml.popTag();
        messages.push_back(m);
        
    }
    xml.popTag();
    
    loadState();
    
    citer = messages.begin();
    
    while (getIsValid() && messagesDone.find(citer->messageID) != messagesDone.end()) {
        citer++;
    }
    
    bLoaded = true;
    
//    for (vector<message>::iterator miter = messages.begin(); miter!=messages.end(); miter++) {
//        cout << miter->messageID << " " << miter->time << " " << miter->title << " " << miter->body << endl;
//        for (vector<button>::iterator biter = miter->buttons.begin(); biter!=miter->buttons.end(); biter++) { 
//            cout << "\t" << biter->text << " " << biter->link << endl;
//        }
//    }
    
}

void ofxPopupMessages::loadState() {
    
    messagesDone.clear();
    ofxXmlSettings xml;
    if (xml.loadFile("popups_state.xml")) {
    
       // citer = messages.begin()+xml.getAttribute("state", "playhead", 0);
        xml.pushTag("state");
        for (int i=0;i<xml.getNumTags("message");i++) {
            messagesDone.insert(xml.getAttribute("message", "id", 0,i));
        }
        
        xml.popTag();
        
        cout << "done:";
        for (set<int>::iterator miter = messagesDone.begin(); miter!=messagesDone.end(); miter++) {
            cout << " " << *miter ;
        }
        
        cout << endl;
    }
    
}

void ofxPopupMessages::saveState() {
    ofxXmlSettings xml;
    
    xml.addTag("state");
    //xml.setAttribute("state", "playhead", distance(messages.begin(), citer),0);
    
    xml.pushTag("state");
    
    for (set<int>::iterator miter = messagesDone.begin(); miter!=messagesDone.end(); miter++) {
        xml.addTag("message");
        xml.addAttribute("message", "id", *miter,distance(messagesDone.begin(), miter));
    }
    xml.popTag();
    
    xml.saveFile("popups_state.xml");
}

message &ofxPopupMessages::getMessage() {
    return *citer;
}


void ofxPopupMessages::nextMessage(bool bDone) {
    if (getIsValid()) {
        if (bDone) {
            messagesDone.insert(citer->messageID);
            saveState();
        }
        citer++;
    }
   
    while (getIsValid() && messagesDone.find(citer->messageID) != messagesDone.end()) {
        citer++;
    } 
    
    
}

bool ofxPopupMessages::getIsValid() {
    return citer!=messages.end();
    
}


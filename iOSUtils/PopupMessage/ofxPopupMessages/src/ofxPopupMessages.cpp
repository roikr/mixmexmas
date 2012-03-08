//
//  ofxPopupMessages.cpp
//  emptyExample
//
//  Created by Roee Kremer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "ofxPopupMessages.h"
#include "ofxXmlSettings.h"

#define DEFAULT_START_DELAY 5.0

void ofxPopupMessages::setup(string filename,string path,string version) {
    this->filename = filename;
    this->path = path;
    this->version = version;
    bStartMessage = false;
    bStarted = false;
    
}


void ofxPopupMessages::load() {
    
   
    messages.clear();
    bStartMessage = false;
    
    ofxXmlSettings xml;
    xml.loadFile(path+'/'+filename); 
    
    startDelay = xml.getAttribute("timeline", "startDelay", DEFAULT_START_DELAY) ;
    
    xml.pushTag("timeline");
    
    for (int i=0; i<xml.getNumTags("message"); i++) {
        message m;
        m.messageID = xml.getAttribute("message", "id", 0,i);
        m.time = xml.getAttribute("message", "time", 0.0,i) ;
        
        xml.pushTag("message",i);
        m.title = xml.getValue("title", "");
        m.body = xml.getValue("body", "");
        for (int j=0; j<xml.getNumTags("button"); j++) {
            button b;
            b.link = xml.getAttribute("button", "link", "",j);
            b.retry = xml.getAttribute("button", "retry", 0,j);
            b.text = xml.getValue("button","",j);
            
            m.buttons.push_back(b);
        }
        xml.popTag();
        
        if (m.time) {
            messages.push_back(m);
        } else if (!bStartMessage) {
            bStartMessage = true;
            startMessage = m;
        }
        
        
    }
    xml.popTag();
    
    
    messagesDone.clear();
    xml.clear();
    if (xml.loadFile(path+"/popups_state.xml")) {
        
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
   
    
    xml.clear();
    if (xml.loadFile(path+"/playhead_"+version+".xml")) {
        nextDelay = xml.getAttribute("playhead", "nextDelay",startDelay);
        citer = messages.begin()+xml.getAttribute("playhead","message",0);;
        
        
    } else {
        citer = messages.begin();
        nextDelay = citer->time;
        
    }
    
    if (citer!=messages.end()) {
        cout << "load\tplayhead: " << distance(messages.begin(), citer)  << ", nextDelay: " << nextDelay << ", messageTime: " << citer->time << endl;
    }
    
    bStarted = false; // to skip first nextMessage after loaded
    
    
//    for (vector<message>::iterator miter = messages.begin(); miter!=messages.end(); miter++) {
//        cout << "id: " << miter->messageID << ", time: " << miter->time << ", title: " << miter->title << ", body: " << miter->body << endl;
//        for (vector<button>::iterator biter = miter->buttons.begin(); biter!=miter->buttons.end(); biter++) { 
//            cout << "\tbutton: " << biter->text << " " << biter->link << endl;
//        }
//    }
    
}

void ofxPopupMessages::save() {
    
    ofxXmlSettings xml;
    
    xml.addTag("state");
    
    xml.pushTag("state");
    
    for (set<int>::iterator miter = messagesDone.begin(); miter!=messagesDone.end(); miter++) {
        xml.addTag("message");
        xml.addAttribute("message", "id", *miter,distance(messagesDone.begin(), miter));
    }
    xml.popTag();
    
    xml.saveFile(path+"/popups_state.xml");
    
    
    if (bStarted) {
        xml.clear();
        
        xml.addTag("playhead");
        xml.addAttribute("playhead", "message",distance(messages.begin(), citer),0);
        if (citer!=messages.end()) {
            //        nextDelay = max(citer->time - min((double)(ofGetElapsedTimeMillis()-timer)/1000.0,citer->time),startDelay);
            float prevDelay = min((double)(ofGetElapsedTimeMillis()-timer)/1000.0,nextDelay);
            nextDelay = max(nextDelay - prevDelay,startDelay);
            xml.addAttribute("playhead", "nextDelay",nextDelay,0);
            cout << "save\tplayhead: " << distance(messages.begin(), citer)  << ", nextDelay: " << nextDelay << ", messageTime: " << citer->time  << endl;
        }
        
        xml.saveFile(path+"/playhead_"+version+".xml"); 
    }
    
}

void ofxPopupMessages::clear() {
    ofxXmlSettings xml;
    xml.saveFile(path+"/playhead_"+version+".xml"); 
}


    


void ofxPopupMessages::nextMessage() {
    
    if (bStarted) {
        if (citer!=messages.end()) {
            citer++;
        }
        
        while (citer!=messages.end() && messagesDone.find(citer->messageID) != messagesDone.end() ) {
            citer++;
        } 
        
        if (citer!=messages.end()) {
            nextDelay = citer->time;
        }
        
    } else {
        bStarted = true;
    }
    
   timer = ofGetElapsedTimeMillis();
    
}





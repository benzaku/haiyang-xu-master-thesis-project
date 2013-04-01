//
//  main.cpp
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/13/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#include <iostream>
#include "PMStreamServer.h"

#include "Poco/DOM/Document.h"
#include "Poco/DOM/Element.h"
#include "Poco/DOM/Text.h"
#include "Poco/DOM/AutoPtr.h"
#include "Poco/DOM/DOMWriter.h"
#include "Poco/XML/XMLWriter.h"
#include <stdio.h>
#include <jpeglib.h>

using Poco::XML::Document;
using Poco::XML::Element;
using Poco::XML::Text;
using Poco::XML::AutoPtr;
using Poco::XML::DOMWriter;
using Poco::XML::XMLWriter;


int main(int argc, char** argv)
{

    // insert code here... haha lala
    std::cout << "Starting PMStreamServer ... \n";
    
    PMStreamServer pmStreamServer;
    
    
    
    return pmStreamServer.run(argc, argv);
    
    
    
    
}


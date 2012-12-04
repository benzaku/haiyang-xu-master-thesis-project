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
    
    
    /******* test poco xml *****/
    AutoPtr<Document> pDoc = new Document;
	
	AutoPtr<Element> pRoot = pDoc->createElement("root");
	pDoc->appendChild(pRoot);
    
	AutoPtr<Element> pChild1 = pDoc->createElement("child1");
	AutoPtr<Text> pText1 = pDoc->createTextNode("text1");
	pChild1->appendChild(pText1);
	pRoot->appendChild(pChild1);
    
	AutoPtr<Element> pChild2 = pDoc->createElement("child2");
	AutoPtr<Text> pText2 = pDoc->createTextNode("text2");
	pChild2->appendChild(pText2);
	pRoot->appendChild(pChild2);
	
	DOMWriter writer;
	writer.setNewLine("\n");
	writer.setOptions(XMLWriter::PRETTY_PRINT);
	writer.writeNode(std::cout, pDoc);
    
    
    
    return pmStreamServer.run(argc, argv);
    
    
    
    
}


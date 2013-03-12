//
//  PMStreamServer.cpp
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/13/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

//#include <iostream>
#include "PMStreamServer.h"
#include "PMStreamServerHandler.h"
#include "PMFileHandler.h"
#include "PMRepository.h"
#include "ModelRepositoryHandler.h"
#include "VDPMLoader.h"


#include "Poco/Util/HelpFormatter.h"
#include "Poco/Net/ServerSocket.h"
#include "Poco/Net/SocketAcceptor.h"
#include "Poco/Net/SocketReactor.h"
#include "Poco/Thread.h"

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
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


using Poco::Util::HelpFormatter;
using Poco::Net::ServerSocket;
using Poco::Net::SocketAcceptor;
using Poco::Net::SocketReactor;
using Poco::Thread;

PMStreamServer::PMStreamServer(){
    _helpRequested = false;
}

PMStreamServer::~PMStreamServer(){
    
}

void PMStreamServer::initialize(Application& self){
    loadConfiguration();
    ServerApplication::initialize(self);
}

void PMStreamServer::uninitialize(){
    ServerApplication::uninitialize();
}

void PMStreamServer::defineOptions(Poco::Util::OptionSet& options){
    ServerApplication::defineOptions(options);
    options.addOption(Option("help", "h", "display help information on command line arguments").required(false).repeatable(false));
    options.addOption(Option("file", "f", "add a file to send", false, "fileName", true).required(false).repeatable(false));
    options.addOption(Option("volume", "v", "read from volume", false, "volume", false).required(false).repeatable(false));
}

void PMStreamServer::handleOption(const std::string& name, const std::string &value){
    ServerApplication::handleOption(name, value);
    
    if (name == "help")
        _helpRequested = true;
    if (name == "file") {
        PMFileName = value;
    }
    if (name == "volume") {
        useVolume = true;
    }
    
}

void PMStreamServer::displayHelp(){
    HelpFormatter helpFormatter(options());
    helpFormatter.setCommand(commandName());
    helpFormatter.setUsage("OPTIONS");
    helpFormatter.setHeader("An echo server implemented using the Reactor and Acceptor patterns.");
    helpFormatter.format(std::cout);
}

int PMStreamServer::main(const std::vector<std::string> &args){
    if (_helpRequested)
    {
        displayHelp();
    }
    else
    {
        
        modelRepo =  new PMRepository();
        
        std::string ss("/Users/hyx/Development/MasterThesis/repository");
        
        modelRepo->setRepositoryDir(&ss);
        
        modelRepo->initVolumeObjs();
        modelRepo->initMeshObjs();
        
        vector<VolumeObj*> *vols = modelRepo->getVolumeObjs();
        vector<MeshObj*> *meshes = modelRepo->getMeshObjs();
        
        
        for(int i = 0; i < meshes->size(); i ++){
            std::cout << (*meshes)[i]->ObjectFileName << std::endl;
            
        }
        
        AutoPtr<Document> pDoc = modelRepo->getModelObjectsXmlDocument();
        
        modelRepo->generateModelListXmlInfo();
        
       
        
        
        modelListXmlString = modelRepo->getModelListXmlString();
        
        modelListXmlStringLength = modelRepo->getModelListXmlStringLength();
        
        
        VDPMLoader vdpmLoader;
        vdpmLoader.openVDPM("/Users/hyx/Development/MasterThesis/repository/mesh/bunny.spm");
        
        /**/
        
        pmFileHandler = (PMFileHandler*)PMFileHandler::getInstance();
        pmFileHandler->setFileName(PMFileName);
        
        pmLoader = new PMLoader(PMFileName);
        pmLoader->setUseVolume(useVolume);
        pmLoader->loadPM();
        pmLoader->getBaseMeshChunk();
        pmFileHandler->setPMLoader(pmLoader);
        
        
        pmFileHandler->setPMRepository(modelRepo);
        //mrHandler->setPMRepository(modelRepo);
        
                
        std::cout<<"Server Started" << std::endl;
        
        // get parameters from configuration file
        unsigned short port = (unsigned short) config().getInt("EchoServer.port", 9977);
        
        // set-up a server socket
        ServerSocket svs(port);
        // set-up a SocketReactor...
        SocketReactor reactor;
        // ... and a SocketAcceptor
        SocketAcceptor<PMStreamServerHandler> acceptor(svs, reactor);
        // run the reactor in its own thread so that we can wait for 
        // a termination request
        
        Thread thread;
        thread.start(reactor);
        // wait for CTRL-C or kill
        waitForTerminationRequest();
        // Stop the SocketReactor
        reactor.stop();
        thread.join();        
        
        
        
    }
    return Application::EXIT_OK;
}

void
PMStreamServer::getModelListXmlInfo(char * xmlString, int &length)
{
    xmlString = this->modelListXmlString;
    length = this->modelListXmlStringLength;
}











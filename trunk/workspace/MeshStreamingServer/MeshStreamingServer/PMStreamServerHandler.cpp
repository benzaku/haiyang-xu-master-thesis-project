//
//  PMStreamServerHandler.cpp
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/13/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#include <iostream>
#include "PMStreamServerHandler.h"
#include "PMFileHandler.h"
#include "PMLoader.h"
#include <OpenMesh/Core/Utils/Endian.hh>
#include "Poco/Net/StreamSocket.h"
#include "Poco/Net/SocketReactor.h"
#include "Poco/Net/SocketNotification.h"
#include "Poco/Util/ServerApplication.h"
#include "Poco/NObserver.h"

using Poco::Net::StreamSocket;
using Poco::Net::SocketReactor;
using Poco::Net::ReadableNotification;
using Poco::Net::ShutdownNotification;
using Poco::AutoPtr;
using Poco::Util::Application;
using Poco::NObserver;

PMStreamServerHandler::PMStreamServerHandler(StreamSocket& socket, SocketReactor& reactor) : _socket(socket), _reactor(reactor), _pBuffer(new char[BUFFER_SIZE])
{
    Application& app = Application::instance();
    app.logger().information("Connection from " + socket.peerAddress().toString());
    
    _reactor.addEventHandler(_socket, NObserver<PMStreamServerHandler, ReadableNotification>(*this, &PMStreamServerHandler::onReadable));
    _reactor.addEventHandler(_socket, NObserver<PMStreamServerHandler, ShutdownNotification>(*this, &PMStreamServerHandler::onShutdown));
    
    _pmFH = (PMFileHandler*)PMFileHandler::getInstance();
    
    std::cout<<*(_pmFH->getFileName())<<std::endl;
    
    _socket.sendBytes("HELLO", 5);
    
    //pmInfoChunk = new char[BUFFER_SIZE];
    
    //_socket.sendBytes(pmInfoChunk, 5242880);
    
    
    
    std::cout<< "Send Finish!" << std::endl;
    
}

PMStreamServerHandler::~PMStreamServerHandler()
{
    Application& app = Application::instance();
    try
    {
        app.logger().information("Disconnecting " + _socket.peerAddress().toString());
        if(pmInfoChunk)
            delete pmInfoChunk;
    }
    catch (...)
    {
    }
    _reactor.removeEventHandler(_socket, NObserver<PMStreamServerHandler, ReadableNotification>(*this, &PMStreamServerHandler::onReadable));
    _reactor.removeEventHandler(_socket, NObserver<PMStreamServerHandler, ShutdownNotification>(*this, &PMStreamServerHandler::onShutdown));
    delete [] _pBuffer;
}

void
PMStreamServerHandler::onReadable(const AutoPtr<Poco::Net::ReadableNotification> &pNf)
{
    int n = _socket.receiveBytes(_pBuffer, BUFFER_SIZE);
    if (n > 0){
        handleRequest();
    }
    
    else
        delete this;
}



void
PMStreamServerHandler::handleRequest()
{
    
    //std::cout<<_pBuffer << std::endl;
    if(strncmp(_pBuffer, "N_BASE_VERTICES", 15) == 0){
        _temp = _pmFH->getPMLoader()->getNBaseVertices();
        _tempContentPtr = (char *) &_temp;
        std::cout<< "start to send N_BASE_VERTICES = " << _temp << std::endl;
        _templen = sizeof(_temp);
        _socket.sendBytes(_tempContentPtr, _templen);
        std::cout<< "N_BASE_VERTICES sent..." << std::endl; 
    }
    else if (strncmp(_pBuffer, "N_BASE_FACES", 12) == 0) {
        _temp = _pmFH->getPMLoader()->getNBaseFaces();
        _tempContentPtr = (char *) &_temp;
        std::cout<< "start to send N_BASE_FACES = " << _temp << std::endl;
        _templen = sizeof(_temp);
        _socket.sendBytes(_tempContentPtr, _templen);
        std::cout<< "N_BASE_FACES sent..." << std::endl; 
    }
    if (strncmp(_pBuffer, "N_DETAIL_VERTICES", 17) == 0) {
        _temp = (int)(_pmFH->getPMLoader()->getNDetailVertices());
        _tempContentPtr = (char *) &_temp;
        std::cout<< "start to send N_DETAIL_VERTICES = " << _temp << std::endl;
        _templen = sizeof(_temp);
        _socket.sendBytes(_tempContentPtr, _templen);
        std::cout<< "N_DETAIL_VERTICES sent..." << std::endl; 
    }
    if (strncmp(_pBuffer, "N_MAX_VERTICES", 14) == 0) {
        _temp = (int)(_pmFH->getPMLoader()->getNMaxVertices());
        _tempContentPtr = (char *) &_temp;
        std::cout<< "start to send N_MAX_VERTICES = " << _temp << std::endl;
        _templen = sizeof(_temp);
        _socket.sendBytes(_tempContentPtr, _templen);
        std::cout<< "N_MAX_VERTICES sent..." << std::endl; 
    }
    if (strncmp(_pBuffer, "BASE_MESH", 9) == 0) {
        _temp = _pmFH->getPMLoader()->getBaseMeshChunkSize();
        _tempContentPtr = (char *) &_temp;
        std::cout<< "start to send SIZE_OF_BASE_MESH = " << _temp << std::endl;
        _templen = sizeof(_temp);
        _socket.sendBytes(_tempContentPtr, _templen);
        std::cout<< "SIZE_OF_BASE_MESH sent..." << std::endl; 
    }
    if (strncmp(_pBuffer, "ACK_OK_SIZE_OF_BASE_MESH", 24) == 0) {
        //send base mesh
        std::cout<< "start to send BASE_MESH = " << std::endl;
        char * baseMeshChunk = _pmFH->getPMLoader()->getBaseMeshChunk();
        _templen = _pmFH->getPMLoader()->getBaseMeshChunkSize();
        _socket.sendBytes(baseMeshChunk, _templen);
        int nbase = _pmFH->getPMLoader()->getNBaseVertices();
        unsigned int *ii = (unsigned int *)&(baseMeshChunk[nbase * sizeof(MyMesh::Point)]);
        MyMesh::Point * ppp = (MyMesh::Point *) &(baseMeshChunk[(nbase-1) * sizeof(MyMesh::Point)]);
        std::cout << *ppp << std::endl;
        std::cout << "ii " << *ii << std::endl;
        std::cout << "ii +" << *(++ii) << std::endl;
        MyMesh::Point * first = (MyMesh::Point *) baseMeshChunk;
        std::cout << *first << std::endl;
        
        //delete baseMeshChunk;
        std::cout<< "BASE_MESH sent..." << std::endl; 
    }
    
    if (strncmp(_pBuffer, "ACK_OK_BASE_MESH", 16) == 0){
        //prepare for the progressive details to send
        std::cout<< "Prepare Progressive Details " << std::endl;
        _socket.sendBytes("PROGRESSIVE_DETAILS_READY", 25);
        std::cout<< "PROGRESSIVE_DETAILS_READY sent..." << std::endl; 
    }
    if (strncmp(_pBuffer, "PMDETAIL", 8) == 0){
        std::cout<< "Start to send PMDETAIL" << std::endl;
        int chunkSize = sizeof(MyMesh::Point) + 3 * sizeof(unsigned int);
        int totalDetailChunkSize = _pmFH->getPMLoader()->getNDetailVertices() * chunkSize;
        //char* details = _pmFH->getPMLoader()->getDetailsChunk();
        
        pmInfoChunk = _pmFH->getPMLoader()->getDetailsChunk();
        
        _socket.sendBytes(pmInfoChunk, totalDetailChunkSize);
        
        std::cout<< "PMInfo details sent... size = "<<totalDetailChunkSize << std::endl;
        
    }
    
}

void 
PMStreamServerHandler::onShutdown(const AutoPtr<ShutdownNotification>& pNf)
{
    
    delete this;
}



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
#include "PublicIncludes.h"


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
    
    _pmFH->getPMRepository()->generateModelListXmlInfo();

    _mRH = (ModelRepositoryHandler *) ModelRepositoryHandler::getInstance();
    
    _vdpmFH = (VDPMFileHandler *) VDPMFileHandler::getInstance();
    //_mRH->getPMRepository()->generateModelListXmlInfo();
    
    std::cout<<*(_pmFH->getFileName())<<std::endl;
    
    _socket.sendBytes("HELLO", 5, 0);
    
    //pmInfoChunk = new char[BUFFER_SIZE];
    
    //_socket.sendBytes(pmInfoChunk, 5242880);
    
    STREAM_STATE = NONE_STATE;
    
    std::cout<< "Send Finish!" << std::endl;
    temp_data_chunk = NULL;
    
}

PMStreamServerHandler::~PMStreamServerHandler()
{
    Application& app = Application::instance();
    try
    {
        app.logger().information("Disconnecting " + _socket.peerAddress().toString());
        //if(pmInfoChunk)
            //delete pmInfoChunk;
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
        std::cout << "receive length = " << n << std::endl;
        handleRequest();
    }
    
    else
        delete this;
}

#define VSPLIT_LENGTH   80

void
PMStreamServerHandler::handleRequest()
{
    
    //std::cout<<"pbuffer: "<<_pBuffer << std::endl;
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
        int nnn = (int)_pBuffer[8];
        std::cout << "nnn = " << nnn << std::endl;
        int chunkSize = sizeof(MyMesh::Point) + 3 * sizeof(unsigned int);
        int totalDetailChunkSize = _pmFH->getPMLoader()->getNDetailVertices() * chunkSize;
        //char* details = _pmFH->getPMLoader()->getDetailsChunk();
        
        pmInfoChunk = _pmFH->getPMLoader()->getDetailsChunk();
        
        _socket.sendBytes(pmInfoChunk, totalDetailChunkSize);
        
        std::cout<< "PMInfo details sent... size = "<<totalDetailChunkSize << std::endl;
        
    }
    
    if (strncmp(_pBuffer, "SIZE_OF_MODEL_LIST", 18) == 0){
        int length = _pmFH->getPMRepository()->getModelListXmlStringLength() * sizeof(char);
        
        _socket.sendBytes(&length,   sizeof(int));
        
    }
    
    if (strncmp(_pBuffer, "MODEL_LIST", 10) == 0){
        std::cout<< "RETRIEVE MODEL LIST!" << std::endl;
        
        char * xmlstring = nullptr;
        int length;
        
        //_pmFH->getPMRepository()->generateModelListXmlInfo();
        
        xmlstring = _pmFH->getPMRepository()->getModelListXmlString();
        
        length = _pmFH->getPMRepository()->getModelListXmlStringLength();
        
        
        //pmInfoChunk = _pmFH->getPMLoader()->getDetailsChunk();
        
        std::cout << xmlstring << std::endl;
        
        _socket.sendBytes(xmlstring, length * sizeof(char));
        
        //std::cout<< "PMInfo details sent... size = "<<totalDetailChunkSize << std::endl;
        
    }
    
    if (strncmp(_pBuffer, "LOAD_MODEL", 10) == 0){
        std::cout << "load model" << std::endl;
        int *id = (int *)&(_pBuffer[10]);
        std::cout << "nnn = " << *id << std::endl;
        
        bool success = handleLoadModelRequest(*id);
        
        if (success) {
            _socket.sendBytes("load", 4);
        } else {
            _socket.sendBytes("fail", 4);
        }
    }
    
    if (strncmp(_pBuffer, "SPM_BASE_INFO_DATA_SIZE", 23) == 0) {
        std::cout << "retrieve spm base info data size" << std::endl;
        
        char ss[sizeof(int)];
        int size = getSPMBaseInfoDataSize();
        memcpy(ss, &size, sizeof(int));
        _socket.sendBytes(ss, sizeof(int));
    }
    
    if (strncmp(_pBuffer, "SPM_BASE_INFORMATION_DATA", 25) == 0){
        std::cout << "retrieve spm base information data" << std::endl;
        _socket.sendBytes(this->_vdpmFH->getVDPMLoader()->get_base_info_data(), this->_vdpmFH->getVDPMLoader()->get_base_info_data_size());
    }
    
    if (strncmp(_pBuffer, "SYNC_SPM_VIEWING_PARAMS", 23) == 0){
        std::cout << "sync spm viewing params" << std::endl;
        viewparam vp;
        memcpy(&vp, &(_pBuffer[23]), sizeof(viewparam));
        this->_vdpmFH->getVDPMLoader()->update_viewing_parameters(vp.modelViewMatrix, vp.aspect, vp.fovy, vp.tolerance_square);
        
        data_chunk *data = this->_vdpmFH->getVDPMLoader()->adaptive_refinement();
        std::cout << data->size << std::endl;
        char header_size[8 + sizeof(int)];
        strncpy(header_size, data->HEADER, 8);
        memcpy(&header_size[8], &(data->size), sizeof(int));
        
        if(temp_data_chunk != NULL){
            free(temp_data_chunk->data);
            free(temp_data_chunk);
        }
        temp_data_chunk = data;
        current_idx = 0;
        
        _socket.sendBytes(header_size, 8 + sizeof(int));
        //if(data->size > 0)
          //  _socket.sendBytes(data->data, data->size);
    }
    if(strncmp(_pBuffer, "RETRIEVE_SPM_VSPLIT_DATA", 24) == 0){
        std::cout << "retrieveing spm vsplit data size: "<< temp_data_chunk->size << std::endl;
        int sent_bytes = _socket.sendBytes(temp_data_chunk->data, temp_data_chunk->size);
        
    }
    if(strncmp(_pBuffer, "RETRIEVE_VSPLIT_DATA_IDX_NUM", 28) == 0){
        //std::cout << "retrieveing spm vsplit data size: "<< temp_data_chunk->size << std::endl;
        int idx_num[2];
        memcpy(idx_num, &_pBuffer[28], 2 * sizeof(int));
        //std::cout << idx_num[0] << " " << idx_num[1] << std::endl;
        int sent_bytes = 0;
        if(temp_data_chunk != NULL){
            sent_bytes = _socket.sendBytes(&(temp_data_chunk->data[idx_num[0] * VSPLIT_LENGTH]), idx_num[1] * VSPLIT_LENGTH);
        }
        //std::cout << "byte sent " << sent_bytes << std::endl;

    }
    
}

int
PMStreamServerHandler::getSPMBaseInfoDataSize()
{
    
    int size = 0;
    if (this->_vdpmFH->getVDPMLoader()->isMeshLoaded()) {
        size = this->_vdpmFH->getVDPMLoader()->calculateSPMBaseInfoDataSize();
        return size;
    }
    
    
    
    return size;
    
}


bool
PMStreamServerHandler::handleLoadModelRequest(int modelId)
{
    vector<MeshObj *> *meshes = this->_pmFH->getPMRepository()->getMeshObjs();
    vector<VolumeObj *> *vols = this->_pmFH->getPMRepository()->getVolumeObjs();
    
    for (int i = 0; i < meshes->size(); i ++) {
        if(modelId == meshes->at(i)->Id){
            std::cout << "found! mesh!" << std::endl;
            
            if(meshes->at(i)->MeshType == PM){
            
                _pmFH->setFileName(meshes->at(i)->ObjectFilePath);
                _pmFH->setPMLoader(new PMLoader(*_pmFH->getFileName()));
                _pmFH->getPMLoader()->loadPM();
                return true;
            }
            else if(meshes->at(i)->MeshType == SPM){
                std::cout << "load spm" << std::endl;
                
                _vdpmFH->setVDPMLoader(new VDPMLoader(meshes->at(i)->ObjectFilePath));
                _vdpmFH->getVDPMLoader()->loadVDPM();
                
                std::cout << "size : " << sizeof(*_vdpmFH->getVDPMLoader()) << std::endl;
                return true;
            }
            return false;
        }
    }
    
    for (int i = 0; i < vols->size(); i ++){
        if(modelId == vols->at(i)->Id){
            std::cout << "found! vol!" << std::endl;
            return true;
        }
    }
}


void
PMStreamServerHandler::onShutdown(const AutoPtr<ShutdownNotification>& pNf)
{
    
    delete this;
}



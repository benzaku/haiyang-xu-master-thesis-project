//
//  main.cpp
//  MeshStreamingClient_Desktop
//
//  Created by Haiyang Xu on 01.10.12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//


#include "Poco/Net/StreamSocket.h"
#include "Poco/Net/SocketStream.h"
#include "Poco/Net/SocketAddress.h"
#include "Poco/StreamCopier.h"
#include "Poco/Path.h"
#include "Poco/Exception.h"
#include <iostream>
#include <unistd.h>

#include "PMLoader.h"
#include <OpenMesh/Core/Utils/Endian.hh>


using Poco::Net::StreamSocket;
using Poco::Net::SocketStream;
using Poco::Net::SocketAddress;
using Poco::StreamCopier;
using Poco::Path;
using Poco::Exception;


int main(int argc, char** argv)
{
	//const std::string HOST("dict.org");
	//const unsigned short PORT = 2628;
    const std::string HOST("127.0.0.1");
    const unsigned short PORT = 9977;
    int buf = 65536;
    //char content[1024];
    char * content = new char[buf];
    char size = 0;
    
    int nBaseVertices = 0;
    int nBaseFaces = 0;
    int nDetailVertices = 0;
    int nMaxVertices = 0;
    char* baseMesh;
    MyMesh::Point  p;
    unsigned int   i, i0, i1, i2;
    unsigned int   v1, vl, vr;
    PMInfoContainer   pminfos_;
	
	if (argc != 2)
	{
		Path p(argv[0]);
		std::cout << "usage: " << p.getBaseName() << " <term>" << std::endl;
		std::cout << "       looks up <term> in dict.org and prints the results" << std::endl;
		return 1;
	}
	std::string term(argv[1]);
	
	try
	{
        
		SocketAddress sa(HOST, PORT);
		StreamSocket sock(sa);
		SocketStream str(sock);
        
        str.read(content, 5);
        std::cout<<content<<std::endl;
        
        int counter = 0;
        
        std::cout<<++counter << std::endl;
        str << "N_BASE_VERTICES" << std::flush;
        str.read(content, sizeof(int));
        nBaseVertices = *((int *)(content));
        std::cout<<"N_BASE_VERTICES \t"<< *((int *)(content)) << std::endl;
        
        str<<"N_BASE_FACES" << std::flush;
        str.read(content, sizeof(int));
        nBaseFaces = *((int *)(content));
        std::cout<< "N_BASE_FACES    \t" << *((int *)(content)) << std::endl;
        
        str<<"N_DETAIL_VERTICES" << std::flush;
        str.read(content, sizeof(int));
        nDetailVertices = *((int *)(content)) ;
        std::cout<< "N_DETAIL_VERTICES \t" << *((int *)(content)) << std::endl;
        
        str<<"N_MAX_VERTICES" << std::flush;
        str.read(content, sizeof(int));
        nMaxVertices = *((int *)(content));
        std::cout<< "N_MAX_VERTICES   \t" << *((int *)(content)) << std::endl;
        
        str<<"BASE_MESH" << std::flush;
        str.read(content, sizeof(int));
        std::cout<< "SIZE_OF_BASE_MESH \t" << *((int *)(content)) << std::endl;
        
        int base_mesh_size = *((int *)(content));
        if(buf < base_mesh_size){
            buf = base_mesh_size;
            delete content;
            content = new char[buf];
        }
        
        str<<"ACK_OK_SIZE_OF_BASE_MESH" << std::flush;
        str.read(content, base_mesh_size);
        
        baseMesh = new char[base_mesh_size];
        memcpy(baseMesh, content, base_mesh_size);
        
        str<<"ACK_OK_BASE_MESH" << std::flush;
        delete content;
        content = new char[25];
        str.read(content, 25);
        std::cout<< content  << std::endl;
        
        char* msgToSend = new char[8 + 2 * sizeof(size_t)];
        
        const char* PMDETAIL = "PMDETAIL";
        memcpy(msgToSend, PMDETAIL, 8);
        
        std::cout<< sizeof( int) << std::endl;
        
        str.write(msgToSend, 8).flush();
        
        for (int i = 0; i < nDetailVertices; ++i) {
            
            bool swap = OpenMesh::Endian::local() != OpenMesh::Endian::LSB;
            OpenMesh::IO::binary<MyMesh::Point>::restore( str, p,   swap );
            OpenMesh::IO::binary<unsigned int>::restore( str, v1,   swap );
            OpenMesh::IO::binary<unsigned int>::restore( str, vl,   swap );
            OpenMesh::IO::binary<unsigned int>::restore( str, vr,   swap );
            PMInfo pminfo;
            pminfo.p0 = p;
            pminfo.v1 = MyMesh::VertexHandle(v1);
            pminfo.vl = MyMesh::VertexHandle(vl);
            pminfo.vr = MyMesh::VertexHandle(vr);
            pminfos_.push_back(pminfo);
        }
        std::cout<< "end" << std::endl;
        sock.shutdownSend();
        str.clear();
        str.close();
        std::cout<< pminfos_.at(pminfos_.size()-1).p0 << std::endl;
        delete content;
        
	}
	catch (Exception& exc)
	{
		std::cerr << exc.displayText() << std::endl;
		return 1;
	}
	
	return 0;
}

//
//  Singleton.h
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/13/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#ifndef PMStreamServer_Singleton_h
#define PMStreamServer_Singleton_h


using namespace std ;

//singleton class
class Singleton 
{
public:
    static Singleton* getInstance();
    
    ~Singleton();
    
private:
    static bool instanceFlag;
    static Singleton* single;
    //Singleton();
protected:
    Singleton();
};



#endif

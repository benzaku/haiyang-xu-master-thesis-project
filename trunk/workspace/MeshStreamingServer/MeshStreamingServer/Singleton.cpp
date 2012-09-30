//
//  Singleton.cpp
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/14/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#include <iostream>
#include "Singleton.h"

bool Singleton::instanceFlag = false;

Singleton* Singleton::single = NULL;

Singleton* Singleton::getInstance()
{
    if(! instanceFlag)
    {
        single = new Singleton();
        instanceFlag = true;
        return single;
    }
    else
    {
        return single;
    }
}

Singleton::Singleton()
{
    
}

Singleton::~Singleton()
{
    
}




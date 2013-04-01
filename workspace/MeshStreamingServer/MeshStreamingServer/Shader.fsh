//
//  Shader.fsh
//  myOpenGLGame
//
//  Created by Xu Haiyang on 10/9/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}

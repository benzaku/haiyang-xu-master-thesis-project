void
GLHandler::
draw_mesh(VDPMMesh &mesh_){
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    glClearColor(0.65, 0.65, 0.65, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    
    
    glUseProgramObjectARB(_shaderId);
    glUniformMatrix4fvARB(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix);
    glUniformMatrix4fvARB(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix);
    
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, mesh_.points());
    
    glEnableClientState(GL_NORMAL_ARRAY);
    glNormalPointer(GL_FLOAT, 0, mesh_.vertex_normals());
    
    /*
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, mesh_.points());
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 12, mesh_.vertex_normals());
    */
    
	//start rendering
	glBegin(GL_TRIANGLES);
    
    FaceIter fIt = mesh_.faces_begin(), fEnd = mesh_.faces_end();
    ConstFaceVertexIter fvIt;
    for (; fIt!=fEnd; ++fIt)
    {
        fvIt = mesh_.cfv_iter(fIt.handle());
        glArrayElement(fvIt.handle().idx());
        ++fvIt;
        glArrayElement(fvIt.handle().idx());
        ++fvIt;
        glArrayElement(fvIt.handle().idx());
    }
    glEnd();

    //glDisableVertexAttribArray(GLKVertexAttribPosition);
    //glDisableVertexAttribArray(GLKVertexAttribNormal);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    

}



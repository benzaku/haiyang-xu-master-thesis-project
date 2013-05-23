- (void) createVertexNormalBufferMemSpace: (GLsizei) totalVertexNormalSize
{
    glBufferData(GL_ARRAY_BUFFER, totalVertexNormalSize, 0, GL_DYNAMIC_DRAW);

}

- (void) createFaceIndexBufferMemSpace: (GLsizei) totalFaceIndiceSize
{
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, totalFaceIndiceSize, 0, GL_DYNAMIC_DRAW);

}

- (void) mapBaseMeshVertexNormalBufferData: (GLubyte *) data: (GLsizei) size
{
    GLvoid * vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    //transfer the vertex data to the vbo
    memcpy(vbo_buffer, data, size);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}

- (void) mapBaseMeshFaceIndexBufferData: (GLubyte *) data: (GLsizei) size
{
    GLvoid * ibo_buffer = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(ibo_buffer, data, size);
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);

}

- (void) enableAttribPointerForPositionAndNormal
{
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, _positionPointerStride, BUFFER_OFFSET(_positionPointerOffset));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, _normalPointerStride, BUFFER_OFFSET(_normalPointerOffset));
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribNormal);
}

- (void) draw2
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VERTEX_NORMAL_BUFFER_OBJECT);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _FACE_INDEX_BUFFER_OBJECT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, _positionPointerStride, BUFFER_OFFSET(_positionPointerOffset));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, _normalPointerStride, BUFFER_OFFSET(_normalPointerOffset));
    
    glUseProgram(_Program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    int facenumber = [progMeshModel getCurrentFaceNumberCanDraw];
    glDrawElements(GL_TRIANGLES, facenumber * 3, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribNormal);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

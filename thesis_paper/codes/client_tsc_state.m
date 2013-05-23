/* 
 * readData from socket and switch client state
 */
- (void) readData: (NSData *) data withTag: (long) tag : (enum SOCKET_STATE) waitState
{
    switch (waitState) {
        //...
            
        /*
         * request for model list sent. wait for model list
         */
        case SOCKET_WAIT_FOR_MODEL_LIST:
            //...
            break;
        /*
         * request to load model. wait for base model
         */
        case SOCKET_WAIT_SERVER_LOAD_MODEL:
           //...
            break;
        /*
         * reqeust server rendered image. wait for image
         */
        case SOCKET_WAIT_FOR_SERVER_RENDERING_IMG:
            //...
            break;
        /*
         * request vsplit data. wait for vsplit
         */
        case SOCKET_WAIT_FOR_SPM_VSPLIT_DATA:
            //...
            break;
        //...
        default:
            break;
    }
    
}


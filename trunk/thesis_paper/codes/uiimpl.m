//
//  ProgMeshGLKViewController.h

#import <GLKit/GLKit.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
@interface ProgMeshGLKViewController : GLKViewController{
	//class fields	
	...
}
//member functions
...
@end


#import <UIKit/UIKit.h>
@interface ProgMeshModelTableViewController : UITableViewController{
	//class fields
	...
}
//member functions
...
@end


#import <UIKit/UIKit.h>
@interface ConfigViewController : UIViewController{
}
@property (retain, nonatomic) IBOutlet UITextField *serverHost;
@property (retain, nonatomic) IBOutlet UITextField *serverPort;
@property (retain, nonatomic) IBOutlet UILabel *statusBar;
@property (retain, nonatomic) IBOutlet UIButton *connectButton;
@property (retain, nonatomic) IBOutlet UISwitch *serverRenderSwitch;
- (IBAction)ServerRenderingChanged:(UISwitch *)sender forEvent:(UIEvent *)event;
- (IBAction)serverConnect:(UIButton *)sender;
@end

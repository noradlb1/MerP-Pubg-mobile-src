

#import <UIKit/UIKit.h>
#import "Drawst.h"

@class JFPlayer, JFProps, JFPlayerPool, JFPropsPool;

@interface IFuckYou : NSObject

@property (nonatomic, assign) bool isFire;

@property (nonatomic, strong) JFPlayer *localPlayer;
@property (nonatomic, strong) NSMutableArray *playerList;
@property (nonatomic, strong) NSMutableArray *propsList;

@property (nonatomic, assign) kaddr lockActor;

@property (nonatomic, strong) JFPlayerPool *playerPool;
@property (nonatomic, strong) JFPropsPool *propsPool;

@property (nonatomic, strong) JFOverlayView *overlayView;
@property (nonatomic, strong) JFFloatingMenuView *floatingMenuView;

+ (IFuckYou *)getInstance;


- (void)entry;
//QQ654153159
- (void)cancelTimer;

@end

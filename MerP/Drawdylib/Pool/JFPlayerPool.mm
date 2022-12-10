#import "JFPlayerPool.h"
#import "Drawlm.h"

@implementation JFPlayerPool

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

 

- (JFPlayer *)getObjFromPool
{
    JFPlayer *player = [super getObjFromPool];
    player.isBestAimTarget = false;
    return player;
}

- (id)create
{
    return [[JFPlayer alloc] init];
}

- (BOOL)validate:(id)obj
{
    return obj != nil;
}

- (void)recycObj:(id)obj
{
    obj = nil;
}

@end

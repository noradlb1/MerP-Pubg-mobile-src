#import "JFPropsPool.h"
#import "Drawdk.h"

@implementation JFPropsPool

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}
  
- (id)create
{
    return [[JFProps alloc] init];
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

#import "JFObjectPool.h"

@implementation JFObjectPool

- (id)init
{
    if(self = [super init]) {
        self.inUseList = [NSMutableArray array];
        self.availableList = [NSMutableArray array];
    }
    return self;
}
 

- (id)getObjFromPool
{
    __block id tmpObj;
    if (self.availableList.count > 0) {
        __weak typeof(self) weakSelf = self;
        [self.availableList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* _Nonnull stop) {
            tmpObj = obj;
            if ([weakSelf validate:obj]) {
                [weakSelf.availableList removeObject:tmpObj];
                [weakSelf.inUseList addObject:tmpObj];
                *stop = YES;
            } else {
                [weakSelf.availableList removeObject:tmpObj];
                [weakSelf recycObj:tmpObj];
                *stop = true;
            }
            
        }];
    } else {
        tmpObj = [self create];
        [self.inUseList addObject:tmpObj];
    }
    return tmpObj;
}
   
- (void)putObj2Pool:(id)obj
{
    [self.inUseList removeObject:obj];
    if ([self validate:obj]) {
        [self.availableList addObject:obj];
    } else {
        [self recycObj:obj];
    }
}

- (id)create
{
    return [[NSObject alloc] init];
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

#import "JFObjectPool.h"
@class JFPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface JFPlayerPool : JFObjectPool

@property (nonatomic, strong) JFPlayer *player;

  

- (JFPlayer *)getObjFromPool;

@end

NS_ASSUME_NONNULL_END

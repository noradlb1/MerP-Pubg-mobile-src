


#import <UIKit/UIKit.h>
#import "JFCommon.h"
#import <string>

NS_ASSUME_NONNULL_BEGIN

@interface JFProps : NSObject

@property (nonatomic, assign) long base;
@property (nonatomic) std::string name;
@property (nonatomic, assign) PropsType type;
@property (nonatomic) Vector3 worldPos;
@property (nonatomic, assign) Vector2 screenPos;
@property (nonatomic, assign) int distance;

@end

NS_ASSUME_NONNULL_END

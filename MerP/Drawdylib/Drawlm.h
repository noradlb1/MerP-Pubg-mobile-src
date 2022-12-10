
#import <UIKit/UIKit.h>
#import "JFCommon.h"
#import <vector>
#import <string>

NS_ASSUME_NONNULL_BEGIN

@interface JFPlayer : NSObject

@property (nonatomic, assign) long base;
@property (nonatomic, assign) int teamNo;
@property (nonatomic, assign) bool isAI;
@property (nonatomic) std::string name;
@property (nonatomic, assign) UInt32 playerKey;
@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int maxHp;
@property (nonatomic, assign) int signalHP;
@property (nonatomic, assign) int signalHPMax;
@property (nonatomic, assign) bool isFallDown;
@property (nonatomic, assign) bool isDead;
@property (nonatomic, assign) bool isVisible;

@property (nonatomic, assign) PlayerType type;
@property (nonatomic) Vector3 worldPos;
@property (nonatomic, assign) CGRect box;

@property (nonatomic, assign) int distance;
@property (nonatomic, assign) bool isBestAimTarget;

@property (nonatomic) BoneData boneData;
@property (nonatomic) BoneVisibleData boneVisibleData;

@end


NS_ASSUME_NONNULL_END

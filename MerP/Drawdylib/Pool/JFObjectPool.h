#import <Foundation/Foundation.h>

@protocol ObjPoolListener<NSObject>
 
@required
- (id)create;

- (BOOL)validate:(id)obj;

- (void)recycObj:(id)obj;

- (id)getObjFromPool;

  
- (void)putObj2Pool:(id)obj;

   
@end

@interface JFObjectPool : NSObject<ObjPoolListener>

@property (nonatomic, strong) NSMutableArray *inUseList;
@property (nonatomic, strong) NSMutableArray *availableList;

@end


//
//  Tools.h
//  CYClear
//
//  Created by jingwei on 2025/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject

+ (void)toast:(NSString *)text;

// 正则获取文件包含的类
+ (NSArray<NSString *> *)getContainsClass:(NSString *)content;

// 过滤白名单
+ (NSArray<NSString *> *)getUnuseClassWithAllUnuse:(NSArray *)unuse;

+ (NSString *)getClassName:(NSString *)text;

// 获取 代码文件中的 作者
+ (NSString *)getCreater:(NSString *)input;
@end

NS_ASSUME_NONNULL_END

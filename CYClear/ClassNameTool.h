//
//  ClassNameTool.h
//  HSFCollatingFiles
//
//  Created by 胡双飞 on 2017/9/13.
//  Copyright © 2017年 胡双飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassNameTool : NSObject

@property (nonatomic,copy) void(^unUsedClassBlock) (NSString *unUsedClassString,NSInteger count);

- (BOOL)searchWithFilePath:(NSString *)path ununseClass:(NSArray *)classs;

@end

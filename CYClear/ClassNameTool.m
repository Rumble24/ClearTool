//
//  ClassNameTool.m
//  HSFCollatingFiles
//
//  Created by 胡双飞 on 2017/9/13.
//  Copyright © 2017年 胡双飞. All rights reserved.
//

#import "ClassNameTool.h"
#import <Cocoa/Cocoa.h>
#import "Tools.h"

typedef NS_ENUM(NSUInteger, OperateType) {
    OperateType_GetAllClass = 1,
    OperateType_GetOneFile = 2,
    OperateType_DeletStorybord = 3
};

@interface ClassNameTool ()
@property (nonatomic, strong) NSString *xcode_PbxprojPath;
@property (nonatomic, strong) NSString *xcode_projectPath;
@property (nonatomic, strong) NSDictionary *xcode_Pbx_objects;
@property (nonatomic, strong) NSMutableDictionary *classCreated;

@property (nonatomic,strong) NSArray *unuse;
@end

@implementation ClassNameTool

- (instancetype)init {
    self = [super init];
    self.classCreated = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}


- (BOOL)searchWithFilePath:(NSString *)path ununseClass:(NSArray *)classs {
    if(!path || ![path hasSuffix:@".xcodeproj"]) {
        [Tools toast:@" “Xcodeproj” path input error"];
        return NO;
    }
    self.unuse = classs;
    [self.classCreated removeAllObjects];
    [self dealWithXcodeproj:path];
    return YES;
}

- (void)dealWithXcodeproj:(NSString *)path {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.xcode_projectPath = [path stringByDeletingLastPathComponent];
        self.xcode_PbxprojPath = [path stringByAppendingPathComponent:@"project.pbxproj"];
        NSDictionary *pbxprojDic = [NSDictionary dictionaryWithContentsOfFile:self.xcode_PbxprojPath];
        
        self.xcode_Pbx_objects = [pbxprojDic objectForKey:@"objects"];
        NSString *uuid_mainGroup = [[self.xcode_Pbx_objects objectForKey:[pbxprojDic objectForKey:@"rootObject"]] objectForKey:@"mainGroup"];
        NSDictionary *PBXGroupDic = [self.xcode_Pbx_objects objectForKey:uuid_mainGroup];
        [self classPath:self.xcode_projectPath pbxGroupDic:PBXGroupDic uuid:uuid_mainGroup operateType:OperateType_GetOneFile];
        
        NSMutableDictionary<NSString *, NSMutableArray *> *name = [NSMutableDictionary dictionary];
        NSMutableString *unString= [NSMutableString string];
        for (NSString *className in self.unuse) {
            if (self.classCreated[className]) {
                NSMutableArray *mArr = name[self.classCreated[className]];
                if (mArr == nil) {
                    mArr = [NSMutableArray array];
                    name[self.classCreated[className]] = mArr;
                }
                [mArr addObject:className];
            } else {
                NSLog(@"error 不存在的类 : %@", className);
                if (className.length > 0) {
                    [unString appendFormat:@"\n%@",className];
                }
            }
        }
        
        for (NSString *key in name.allKeys) {
            [unString appendFormat:@"\n"];
            NSMutableArray *mArr = name[key];
            for (NSString *className in mArr) {
                [unString appendFormat:@"\nCreated by %@ - %@", key, className];
            }
        }
        
        if (self.unUsedClassBlock) {
            self.unUsedClassBlock(unString,self.unuse.count);
            
        }
    });
    
}


- (void)classPath:(NSString*)classPath pbxGroupDic:(NSDictionary*)pbxGroupDic uuid:(NSString*)uuid operateType:(OperateType)operateType {
    
    NSArray* children = pbxGroupDic[@"children"];
    NSString* path = pbxGroupDic[@"path"];
    NSString* sourceTree = pbxGroupDic[@"sourceTree"];
    
    if (path.length > 0) {
        if ([sourceTree isEqualToString:@"<group>"]) {
            classPath = [classPath stringByAppendingPathComponent:path];
        } else if([sourceTree isEqualToString:@"SOURCE_ROOT"]) {
            classPath = [self.xcode_projectPath stringByAppendingPathComponent:path];
        }
    }
    
    if (children.count == 0) {
        NSString *pathExtension = classPath.pathExtension;
        if([pathExtension isEqualToString:@"h"] || [pathExtension isEqualToString:@"m"]||[pathExtension isEqualToString:@"pch"] ||  [pathExtension isEqualToString:@"storyboard"]|| [pathExtension isEqualToString:@"mm"] || [pathExtension isEqualToString:@"xib"] || [pathExtension isEqualToString:@"swift"]) {
            [self examineClassFilePath:classPath];
        }
    } else {
        for (NSString* childrenUUid in children) {
            NSDictionary* childrenDic = self.xcode_Pbx_objects[childrenUUid];
            [self classPath:classPath pbxGroupDic:childrenDic uuid:childrenUUid operateType:operateType];
        }
    }
}


- (void)examineClassFilePath:(NSString*)classFilePath {
    NSString *content = [NSString stringWithContentsOfFile:classFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *Created = [Tools getCreater:content];
    if (Created.length > 0) {
        NSArray *classs = [Tools getContainsClass:content];
        for (NSString *class in classs) {
            [self.classCreated setValue:Created forKey:class];
        }
    }
}

@end

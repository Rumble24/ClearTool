//
//  Tools.m
//  CYClear
//
//  Created by jingwei on 2025/7/22.
//

#import "Tools.h"
#import <Cocoa/Cocoa.h>

@implementation Tools

+ (void)toast:(NSString *)text {
    if (!text || text.length == 0) return;
    NSAlert* errorAlert = [[NSAlert alloc] init];
    errorAlert.messageText = text;
    [errorAlert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
}

+ (NSArray<NSString *> *)getContainsClass:(NSString *)input {
    NSMutableArray *result = [NSMutableArray array];
    NSString *pattern = @"(@interface|class)\\s+(\\w+)\\s*(:|\\{|\\n|$)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];

    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:input options:0 range:NSMakeRange(0, input.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange classNameRange = [match rangeAtIndex:2];
        NSString *className = [input substringWithRange:classNameRange];
        [result addObject:className];
        //NSLog(@"有效类名: %@", className); // 输出: User（忽略 getUser）
    }
    
    return result;
}


+ (NSArray<NSString *> *)getUnuseClassWithAllUnuse:(NSArray *)unuse {
    NSString *path1 = [NSBundle.mainBundle pathForResource:@"whitelist" ofType:@"txt"];
    NSString *content1 = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path1] encoding:NSMacOSRomanStringEncoding error:nil];
    NSArray *whitelist = [content1 componentsSeparatedByString:@"\n"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@)", whitelist];
    return [unuse filteredArrayUsingPredicate:predicate];
}

+ (NSString *)getClassName:(NSString *)text {
    if ([text containsString:@"."]) {
        NSArray *result = [text componentsSeparatedByString:@"."];
        return result.lastObject;
    }
    return text;
}


+ (NSString *)getCreater:(NSString *)input {
    NSString *pattern = @"by\\s+([^\\s]+)\\s+on";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];

    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:input options:0 range:NSMakeRange(0, input.length)];
    if (matches.count > 0) {
        NSTextCheckingResult *match = matches[0];
        NSRange nameRange = [match rangeAtIndex:1];
        NSString *name = [input substringWithRange:nameRange];
        return name;
    }
    return @"";
}

@end

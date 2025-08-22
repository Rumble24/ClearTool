//
//  ViewController.m
//  CYClear
//
//  Created by jingwei on 2025/7/22.
//
/*
 相关底层知识
 Swift结构体底层StructMetadata： https://juejin.cn/post/6919717099619221517
 */
#import "ViewController.h"
#import "ClassNameTool.h"
#import "Tools.h"
#import <WBBlades/WBBladesInterface.h>
#import <WBBlades/WBBladesScanManager.h>

@interface ViewController()
@property (weak) IBOutlet NSTextField *projectPath;
@property (weak) IBOutlet NSButton *browerBtn;
@property (weak) IBOutlet NSTextField *debugIpa;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSButton *startSearchBtn;
@property (unsafe_unretained) IBOutlet NSTextView *unUsedFilesTextView;

@property(nonatomic,strong) NSOpenPanel *openPanel;
@property(nonatomic,strong) ClassNameTool *classNameTool;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.classNameTool = [ClassNameTool new];
    
    [WBBladesInterface.shareInstance addObserver:self forKeyPath:@"unusedClassInfos" options:NSKeyValueObservingOptionNew context:nil];

    [self.projectPath becomeFirstResponder];

    __weak typeof(self) weakSelf = self;
    [self.classNameTool setUnUsedClassBlock:^(NSString *unString,NSInteger count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.unUsedFilesTextView.string = [NSString stringWithFormat:@"%@\n\n过滤白名单之后的类：%@",weakSelf.unUsedFilesTextView.string,unString];
            [weakSelf.unUsedFilesTextView scrollRectToVisible:NSMakeRect(0, 0, 0, 0)];
        });
    }];
}

- (IBAction)startSearchAction:(id)sender {
    NSString *projectPath = self.projectPath.stringValue;
    if (!projectPath || ![projectPath hasSuffix:@".xcodeproj"]) {
        [Tools toast:@"请输入正确的 “Xcodeproj” 路径"];
        return;
    }
    
    NSString *ipaPath = self.debugIpa.stringValue;
    if(!ipaPath || ipaPath.length == 0) {
        [Tools toast:@"请输入正确的 “debug 调试包” 路径"];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray<NSDictionary<NSString *, NSNumber *> *> *unUsedClassResultSet = [WBBladesInterface scanUnusedClassWithAppPath:ipaPath fromLibs:@[]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableString *unString= [NSMutableString stringWithFormat:@"%@\n\n检测到所有未使用过的类：\n",self.unUsedFilesTextView.string];
            NSMutableArray *unuse = [NSMutableArray array];
            for (NSDictionary *dict in unUsedClassResultSet) {
                for (NSString *key in dict.allKeys) {
                    [unString appendFormat:@"%@\n", key];
                    
                    NSString *className = [Tools getClassName:key];
                    if (className) [unuse addObject:className];
                    NSLog(@"未使用的类 %@", className);
                }
            }
            self.unUsedFilesTextView.string = unString;

            NSArray *filterUnuse = [Tools getUnuseClassWithAllUnuse:unuse];
            if (filterUnuse.count == 0) {
                self.unUsedFilesTextView.string = [NSString stringWithFormat:@"%@\n\n🎉过滤白名单之后没有未使用过的类\n\n\n\n",self.unUsedFilesTextView.string];
            } else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self.classNameTool searchWithFilePath:projectPath ununseClass:filterUnuse];
                });
            }
        });
    });
}


- (IBAction)browerAction:(id)sender {
    self.projectPath.stringValue = @"";
    if (self.openPanel) {
        [self.openPanel close];
        self.openPanel = nil;
    }
    self.openPanel = [NSOpenPanel openPanel];
    [self.openPanel setCanChooseDirectories:YES];
    [self.openPanel setCanChooseFiles:YES];
    self.openPanel.allowsMultipleSelection = NO;
    [self.openPanel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSString *path = [[self.openPanel URL] path];
            self.projectPath.stringValue = path;
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.unUsedFilesTextView.string = WBBladesInterface.shareInstance.unusedClassInfos;
    });
}
@end

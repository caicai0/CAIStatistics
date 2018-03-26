//
//  ViewController.m
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "ViewController.h"
#import "CAIStatistic.h"
#import "SRPAspects.h"
#import "CAISUtils.h"

@interface TestClass:NSObject

- (void)noArgFunction;
- (void)argFunction:(id)arg;

@end

@implementation TestClass

- (void)noArgFunction{
    
}
- (void)argFunction:(id)arg{
    
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ViewController.title";
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [CAIStatistic startInLocalPath:documentsDirectory];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testClicked:(id)sender {
    TestClass * test = [[TestClass alloc]init];
    [test noArgFunction];
    [test argFunction:self];
    
    Class device = NSClassFromString(@"UIScreen");
    SEL selector = NSSelectorFromString(@"mainScreen");
    NSString * dev = [CAISUtils objectForClass:device selector:selector keyPath:@"bounds"];
    NSLog(@"%@",dev.description);
}



@end

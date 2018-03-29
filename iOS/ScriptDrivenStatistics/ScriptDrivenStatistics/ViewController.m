//
//  ViewController.m
//  ScriptDrivenStatistics
//
//  Created by caicai on 2018/3/27.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import "ViewController.h"

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
    [NSBundle mainBundle].infoDictionary;
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
    
}



@end

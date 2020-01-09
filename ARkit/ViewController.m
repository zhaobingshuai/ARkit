//
//  ViewController.m
//  ARkit
//
//  Created by gaoyi on 2019/1/18.
//  Copyright © 2019年 ShenZhen University. All rights reserved.
//

#import "ViewController.h"
#import "ARSCNViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//开始
- (IBAction)szh_openARView:(id)sender {
    
    ARSCNViewController *arscnView =  [[ARSCNViewController alloc]init];
    [self presentViewController:arscnView animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

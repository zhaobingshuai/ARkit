//
//  main.m
//  Demo_1
//
//  Created by nethanhan on 2017/9/18.
//  Copyright © 2017年 ArWriter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool
    {
////      filepath为创建文件的路径
//        NSString *filepath = [NSString stringWithFormat:@"%@/SlamData.txt",NSHomeDirectory()];
//        NSLog(@"filePath = %@",filepath);
//        NSString *strdata = @"这是文件内容!!!";
//        // 将字符串转换成NSData 这是字符串对象的方法
//        NSData *data = [strdata dataUsingEncoding:NSUTF8StringEncoding];
////      NSFileManager 是一个专门用来管理文件和文件夹的类，创建文件管理器对象
//        NSFileManager *fm = [NSFileManager defaultManager];
//
////        创建文件
//        [fm createFileAtPath:filepath contents:data attributes:nil];
//        //判断文件是否存在 不存在就结束程序
//       if(![[NSFileManager defaultManager] fileExistsAtPath:filepath])
//        {
//            NSLog(@"文件不存在");//为什么这里新建文件不成功呢？
//            [[NSFileManager defaultManager] createFileAtPath:filepath contents:data attributes:nil];
//            return 1;
//        }
//
//        // 向文件中写内容，通过文件句柄，NSFileHandle实现
//        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
//        [fileHandle writeData:data];
//        //        输出文件内容到output
//        NSLog(@"%@",[NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil]);
//        // 关闭文件
//        [fileHandle closeFile];
         return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
    return 0;
}



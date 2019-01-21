//
//  ViewController.m
//  ARkit
//
//  Created by gaoyi on 2019/1/18.
//  Copyright © 2019年 ShenZhen University. All rights reserved.
//

#import "ARSCNViewController.h"
//先导入SceneKit(3D游戏框架)
#import <SceneKit/SceneKit.h>
//后导入ARKit框架
#import <ARKit/ARKit.h>
#import "ViewController.h"
#import <Foundation/Foundation.h>

//定义π值 3.1415926，将欧拉角换算成度数
#define PI 3.1415926

@interface ARSCNViewController ()<ARSCNViewDelegate,ARSessionDelegate>


//AR会话，负责管理相机追踪配置及3D相机坐标
@property (nonatomic, strong) ARSession *session;
@property (nonatomic, strong) ARFrame *frame;
// 会话追踪配置：负责追踪相机的运动
@property (nonatomic, strong) ARConfiguration *sessionConfig;
//定义旋转变换矩阵
@property (nonatomic, readonly) matrix_float4x4 transform;
//定义欧拉角
@property (nonatomic, readonly) vector_float3 eulerAngles;
//时间戳是自手机启动以来的秒数。
@property (nonatomic, readonly) NSTimeInterval timestamp;
// AR视图，用于展示相机捕捉到的画面
@property (nonatomic, strong) ARSCNView *scnView;
// 遮罩视图，当状态异常时充当蒙版遮罩
@property (nonatomic, strong) UIView *maskView;
// 提示信息标签
@property (nonatomic, strong) UILabel *tipLabel;
// 位姿信息标签
@property (nonatomic, strong) UILabel *infoLabel;
@end

@implementation ARSCNViewController

dispatch_queue_t trackingQueue;
int count = 1;  //count用来统计数据的组数，用于后续分析
UInt64 BeginTime;//定义为启动APP那一刻的时间

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加AR视图和界面元素
    [self.view addSubview:self.scnView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.infoLabel];
    
    // 设置AR视图代理
    self.scnView.delegate = self;
    // 显示视图的FPS信息和其他参数
    self.scnView.showsStatistics = YES;
    trackingQueue = dispatch_queue_create("tracking", DISPATCH_QUEUE_SERIAL);
}

//设置停止按钮，返回到开始界面
- (void)back:(UIButton *)btn
{
    //假设从A控制器通过present的方式跳转到了B控制器，dismiss回到A控制器
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 运行视图中自带的会话，ARSession运行后会启动一个名为VIOEngineNode的线程，然后初始化传感器、调用ARTechnique的各个子类
    [self.scnView.session runWithConfiguration:self.sessionConfig];
    
    // 添加停止按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"停止" forState:UIControlStateNormal];
    //控制按钮的左右位置，上下位置以及按钮大小
    btn.frame = CGRectMake(self.view.bounds.size.width / 2 - 50, self.view.bounds.size.height - 250, 100, 50);
    btn.backgroundColor = [UIColor redColor];//设置按钮颜色为红色
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 暂停运行当前视图自带的session
    [self.scnView.session pause];
}


- (void) session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
    matrix_float4x4 transform = self.scnView.session.currentFrame.camera.transform;
    vector_float3 eulerAngles = self.scnView.session.currentFrame.camera.eulerAngles;
    UInt64 CurrentTime = self.scnView.session.currentFrame.timestamp*1000;//定义为当前帧对应的时间戳，单位为秒，乘1000后单位为毫秒
    
    //      filepath为创建文件的路径
    NSString *filepath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/SlamData.txt"];
    //      NSFileManager 是一个专门用来管理文件和文件夹的类，创建文件管理器对象
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(count == 1)//只在第一次调用didUpdateFrame时创建文件，否则每次调用都会创建新文件覆盖掉原数据
    {
        //创建文件
        [fm createFileAtPath:filepath contents:nil attributes:nil];
        //判断文件是否存在 不存在就结束程序
        if(![[NSFileManager defaultManager] fileExistsAtPath:filepath])
        {
            NSLog(@"文件不存在");
        }
        BeginTime = self.scnView.session.currentFrame.timestamp*1000;//刚启动APP那一刻的时间戳，单位为毫秒
    }
    
    //新建文本文件用于保存位姿数据
    if(self.scnView.session.currentFrame.camera.trackingState == ARTrackingStateNormal)
    {
        // 向文件中写内容，通过文件句柄，NSFileHandle实现
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
        
        //找到并定位到fileHandle的末尾位置(在此后追加文件)
        [fileHandle seekToEndOfFile];
  
        NSString *stringCount = [NSString stringWithFormat:@"%d ",count];
        NSData *dataCount = [stringCount dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:dataCount];
        
        //当前帧的时间减去开始APP那一刻的时间，就可以使时间从0开始以毫秒计
        NSString *stringTime = [NSString stringWithFormat:@"%llu ",CurrentTime - BeginTime];
        NSData *dataTime = [stringTime dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:dataTime];
        
        NSString *stringPose = [NSString stringWithFormat:@"%f %f %f ",
                                transform.columns[3].x*100,transform.columns[3].y*100,
                                transform.columns[3].z*100];
        NSData *dataPose = [stringPose dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:dataPose];
        
        NSString *stringEulerAngles = [NSString stringWithFormat:@"%f %f %f\n",
                                       (eulerAngles.x/PI)*360,(eulerAngles.y/PI)*360,(eulerAngles.z/PI)*360];
        NSData *dataEulerAngles = [stringEulerAngles dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:dataEulerAngles];
        
        [NSThread sleepForTimeInterval:0.01];   //当前线程,每循环一次,就休眠0.01秒
        
        [fileHandle closeFile];  // 关闭文件
    }
    
    dispatch_async(trackingQueue, ^{
        if(self.scnView.session.currentFrame.camera.trackingState == ARTrackingStateNormal)
        {
            // 输出位姿信息，即transform 4*4的矩阵
            NSLog(@"第%d帧：",count);  //记录帧的顺序，便于数据分析
            
            NSLog(@"时间戳:%llu ms", CurrentTime - BeginTime);
            
            //相机的位置参数在4*4矩阵的第三列
            NSLog(@"东西：%f cm, 上下：%f cm, 南北：%f cm",
                  transform.columns[3].x*100,transform.columns[3].y*100,
                  transform.columns[3].z*100);
            
            //X轴的旋转角称为俯仰角，Y轴的旋转角称为航向角，Z轴的旋转角称为横滚角，欧拉角表示摄像头的角度
            NSLog(@"俯仰角：%f °, 航向：%f °, 横滚：%f °\n",
                  (eulerAngles.x/PI)*360,(eulerAngles.y/PI)*360,(eulerAngles.z/PI)*360); //将欧拉角换算为对应的角度显示
            
            count = count + 1;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.scnView.session.currentFrame.camera.trackingState == ARTrackingStateNormal)
            {
                // 更新界面
                NSMutableString *infoStr = [NSMutableString new];
                
                [infoStr appendString:[NSString stringWithFormat:@"第%d帧：\n",count]];
                self.infoLabel.text = infoStr;
                
                [infoStr appendString:[NSString stringWithFormat:@"时间戳：%llu ms\n",CurrentTime - BeginTime]];
                self.infoLabel.text = infoStr;
                
                [infoStr appendString:[NSString stringWithFormat:@"东西：%f cm\n上下：%f cm\n南北：%f cm\n",
                                       transform.columns[3].x*100,transform.columns[3].y*100,
                                       transform.columns[3].z*100]];
                self.infoLabel.text = infoStr;
                
                [infoStr appendString:[NSString stringWithFormat:@"俯仰角：%f °\n航向角：%f °\n横滚角：%f °\n",
                                       (eulerAngles.x/PI)*360,(eulerAngles.y/PI)*360,(eulerAngles.z/PI)*360]];
                self.infoLabel.text = infoStr;
            }
        });
        [NSThread sleepForTimeInterval:0.01];   //当前线程,每循环一次,就休眠0.01秒
    });
}


#pragma mark - ARSCNViewDelegate
//当跟踪状态正常时，遮罩视图全透明，实时提示；
//当跟踪不可用时，显示遮罩视图，实时提示；
//当跟踪变为有限状态时，显示遮罩视图，实时提示；
- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera
{
    // 判断状态
    switch (camera.trackingState)
    {
        case ARTrackingStateNotAvailable:
        {
            // 当追踪不可用时显示遮罩视图
            self.tipLabel.text = @"追踪不可用";
            NSLog(@"追踪不可用");
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.7;
            }];
        }
            break;
        case ARTrackingStateLimited:
        {
            // 当追踪有限时输出原因并显示遮罩视图，并提示原因
            NSString *title = @"有限的追踪，原因为：";
            NSLog(@"有限的追踪，原因为：");
            NSString *desc;
            // 判断原因
            switch (camera.trackingStateReason)
            {
                case ARTrackingStateReasonNone:
                {
                    desc = @"不受约束";
                    NSLog(@"不受约束");
                }
                    break;
                case ARTrackingStateReasonInitializing:
                {
                    desc = @"正在初始化，请稍等";
                    NSLog(@"正在初始化，请稍等");
                }
                    break;
                case ARTrackingStateReasonExcessiveMotion:
                {
                    desc = @"设备移动过快，请注意";
                    NSLog(@"设备移动过快，请注意");
                }
                    break;
                case ARTrackingStateReasonInsufficientFeatures:
                {
                    desc = @"提取不到足够的特征点，请移动设备";
                    NSLog(@"提取不到足够的特征点，请移动设备");
                }
                    break;
                default:
                    break;
            }
            self.tipLabel.text = [NSString stringWithFormat:@"%@%@", title, desc];
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.6;
            }];
        }
            break;
        case ARTrackingStateNormal:
        {
            // 当追踪正常时遮罩视图隐藏，全透明
            self.tipLabel.text = @"追踪正常";
            NSLog(@"追踪正常");
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.0;
            }];
        }
            break;
        default:
            break;
    }
}

//当出现错误时，只需要提示一下即可，正常情况下用不到
- (void)session:(ARSession *)session didFailWithError:(NSError *)error
{
    // 当会话出错时输出出错信息
    switch (error.code)
    {
            // errorCode=100
        case ARErrorCodeUnsupportedConfiguration:
            self.tipLabel.text = @"当前设备不支持";
            break;
            // errorCode=101
        case ARErrorCodeSensorUnavailable:
            self.tipLabel.text = @"传感器不可用，请检查传感器";
            break;
            // errorCode=102
        case ARErrorCodeSensorFailed:
            self.tipLabel.text = @"传感器出错，请检查传感器";
            break;
            // errorCode=103
        case ARErrorCodeCameraUnauthorized:
            self.tipLabel.text = @"相机不可用，请检查相机";
            break;
            // errorCode=200
        case ARErrorCodeWorldTrackingFailed:
            self.tipLabel.text = @"追踪出错，请重置";
            break;
        default:
            break;
    }
}

//当出现中断时进行提示，当中断结束后重新运行会话进行跟踪
- (void)sessionWasInterrupted:(ARSession *)session
{
    self.tipLabel.text = @"会话中断";
    NSLog(@"会话中断");
}

- (void)sessionInterruptionEnded:(ARSession *)session
{
    self.tipLabel.text = @"会话中断结束，已重置会话";
    [self.scnView.session runWithConfiguration:self.sessionConfig options: ARSessionRunOptionResetTracking];
    NSLog(@"会话中断结束，已重置会话");
}

#pragma mark - lazy

//初始化其他视图：遮罩视图、位姿信息标签、提示标签；
- (UILabel *)infoLabel
{
    if (nil == _infoLabel)
    {
        // 创建显示位姿的Label
        _infoLabel = [[UILabel alloc] init];
        //                               label底部的坐标
        _infoLabel.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), CGRectGetWidth(self.tipLabel.frame), 200);
        _infoLabel.numberOfLines = 0;
        _infoLabel.textColor = [UIColor blackColor];
    }
    
    return _infoLabel;
}

- (UILabel *)tipLabel
{
    if (nil == _tipLabel)
    {
        // 创建提示信息的Label
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.frame = CGRectMake(0, 30, CGRectGetWidth(self.scnView.frame), 50);
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [UIColor blackColor];
    }
    
    return _tipLabel;
}

- (UIView *)maskView
{
    if (nil == _maskView)
    {
        // 创建遮罩视图
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        // 初始状态为白色蒙版遮罩
        _maskView.backgroundColor = [UIColor whiteColor];
        _maskView.alpha = 0.6;
    }
    return _maskView;
}

//由于ARSCNView类中包含ARSession,所以不需要创建会话，只需创建AR视图和会话配置即可
- (ARSCNView *)scnView
{
    if (nil == _scnView)
    {
        //1.创建AR视图
        _scnView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        //2.设置视图会话
        _scnView.session = self.session;
        //3.自动刷新灯光（3D游戏用到，此处可忽略）
        //        _scnView.automaticallyUpdatesLighting = YES;
    }
    return _scnView;
}

//加载会话
- (ARSession *) session
{
    if (_session != nil) {
        return _session;
    }
    //    创建会话
    _session = [ARSession new];
    //    设置会话的代理
    _session.delegate = self;
    
    return _session;
}

- (ARConfiguration *)sessionConfig
{
    
    if (nil == _sessionConfig)
    {
        // 创建会话配置
        if ([ARWorldTrackingConfiguration isSupported]) //判断当前设备是否支持世界跟踪，如果支持，则赋值为世界跟踪类对象
        {
            // 创建可追踪6DOF的会话配置
            ARWorldTrackingConfiguration *worldConfig = [ARWorldTrackingConfiguration new];
            //            指定会话是否要估算场景的光照亮度，（相机从暗到强光快速过渡效果会平缓一些）
            worldConfig.lightEstimationEnabled = YES;
            _sessionConfig = worldConfig;
        }
        else //如果不支持，则赋值为方向跟踪类对象
        {
            // 创建可追踪3DOF的会话配置,此时不支持检测平面和提取特征点
            AROrientationTrackingConfiguration *orientationConfig = [AROrientationTrackingConfiguration new];
            _sessionConfig = orientationConfig;
            self.tipLabel.text = @"当前设备不支持6DOF追踪";
        }
    }
    return _sessionConfig;//带-的叫属性
}

- (IBAction)EndARKit:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end


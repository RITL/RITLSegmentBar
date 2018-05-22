//
//  ViewController.m
//  RITLSegmentBarDemo
//
//  Created by YueWen on 2018/5/22.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "ViewController.h"
#import "RITLSegmentBar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    RITLSegmentBar *bar = [RITLSegmentBar segmentBarWithFrame:CGRectMake(0, 60, 327, 44)];
    bar.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.9];;
    [self.view addSubview:bar];
    
    bar.buttonMarginSpace = 19;
    bar.itemSelectedColor = UIColor.whiteColor;
    bar.itemNormalFont = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    bar.itemSelectedFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:21];
    bar.items = @[@"推荐",@"金融",@"区块链",@"农业政策",@"种植养鱼"];
    bar.selectIndex = 2;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

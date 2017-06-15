//
//  ViewController.m
//  YYRefreshDemo
//
//  Created by user on 2017/6/15.
//  Copyright © 2017年 yy. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+YYRefresh.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,YYRefreshDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataArray = @[].mutableCopy;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.refreshDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    YYRefreshStateModel *model = [self.tableView refreshModelWithState:YYRefreshLoading];
    model.image = [UIImage imageNamed:@"ic_logo_tw"];
    
    [self.tableView beginRefreshing];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]];
    return cell;
}

//MARK: - YYRefreshDelegate
- (void)viewWillRefresh:(UIScrollView *)view
{
    __weak typeof(self) weakSelf = self;
    [self requestDataWithComplate:^(NSArray *array) {
        weakSelf.dataArray = array.mutableCopy;
        weakSelf.tableView.refreshState = YYRefreshDefault;
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillLoadMore:(UIScrollView *)view
{
    __weak typeof(self) weakSelf = self;
    [self requestDataWithComplate:^(NSArray *array) {
        [weakSelf.dataArray addObjectsFromArray:array];
        weakSelf.tableView.refreshState = YYRefreshDefault;
        [weakSelf.tableView reloadData];
    }];
}

- (void)requestDataWithComplate:(void(^)(NSArray *))complate {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)( 2.5* NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        NSMutableArray *array = @[].mutableCopy;
        for (int i =0; i < 20; i ++) {
            [array addObject:@(i).stringValue];
        }
        complate(array);
    });
}

@end

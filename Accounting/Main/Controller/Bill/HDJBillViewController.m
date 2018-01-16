//
//  HDJBillViewController.m
//  Accounting
//
//  Created by 洪冬介 on 2017/7/12.
//  Copyright © 2017年 hongdongjie. All rights reserved.
//

#import "HDJBillViewController.h"
#import "HDJIERecordModel.h"
#import "HDJBillDisplayCell.h"
#import "HDJBillHeaderView.h"
#import "HDJBillFooterView.h"

@interface HDJBillViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<HDJIERecordModel*> *dataArr;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HDJBillHeaderView *headerView;
@property (nonatomic, strong) HDJBillFooterView *footerView;

@end

@implementation HDJBillViewController

#pragma mark - lazy load
-(NSMutableArray<HDJIERecordModel*> *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        [self.dbMgr.database open];
        
        [_dataArr addObjectsFromArray:[HDJIERecordModel mj_objectArrayWithKeyValuesArray:[self.dbMgr getAllTuplesFromTabel:record_income_expenses_table]]];
        
        [self.dbMgr.database close];

    }
    return _dataArr;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor = CLEARCOLOR;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.01, adaptHeight(10))];
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 11.0) {
            _tableView.estimatedSectionHeaderHeight = 10;
            _tableView.estimatedSectionFooterHeight = 0.01;
        }
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = self.footerView;
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _tableView;
}

- (HDJBillHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[HDJBillHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, adaptHeight(HDJBillHeaderView_Height))];
    }
    return _headerView;
}

- (HDJBillFooterView *)footerView{
    if (!_footerView) {
        _footerView = [[HDJBillFooterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, adaptHeight(HDJBillFooterView_Height))];
    }
    return _footerView;
}


#pragma mark - view func
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([USER_DEFAULT boolForKey:NEED_UPDATE_BILL_DATA]) {
        [self.dbMgr.database open];
        
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:[HDJIERecordModel mj_objectArrayWithKeyValuesArray:[self.dbMgr getAllTuplesFromTabel:record_income_expenses_table]]];
        
        [self.dbMgr.database close];

        [self.tableView reloadData];
        [USER_DEFAULT setBool:NO forKey:NEED_UPDATE_BILL_DATA];
        [USER_DEFAULT synchronize];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initNav];
    self.tableView.hidden = NO;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDJIERecordModel* model = self.dataArr[indexPath.row];
    HDJBillDisplayCell* cell = [[HDJBillDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.recordModel = model;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"cell：%ld-%ld",indexPath.section,indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return adaptHeight(HDJBillDisplayCell_Height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return adaptHeight(12);
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

#pragma mark - SEL


#pragma mark - Method
- (void)initNav{
    self.navTitle = @"账单";
    self.view.backgroundColor = CLEARCOLOR;
    UIImageView* bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_pic"]];
    [self.view addSubview:bgImageView];
    bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}


#pragma mark - NetRequest



@end

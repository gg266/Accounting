//
//  HDJEditCategoryController.m
//  Accounting
//
//  Created by 洪冬介 on 2017/7/21.
//  Copyright © 2017年 hongdongjie. All rights reserved.
//

#import "HDJEditCategoryController.h"
#import "HDJAddCategoryController.h"
#import "HDJIncomeExpensesModel.h"
#import "HDJTableViewCell.h"

@interface HDJEditCategoryController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<HDJIncomeExpensesModel*> *itemsArr;

@end

@implementation HDJEditCategoryController

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor = BACKGROUND_COLOR;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = adaptWidth(55);
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.01, 0.01)];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _tableView;
}

- (NSMutableArray<HDJIncomeExpensesModel*> *)itemsArr{
    if (!_itemsArr) {
        _itemsArr = [NSMutableArray array];
        [self.dbMgr.database open];
        
        [_itemsArr addObjectsFromArray:[HDJIncomeExpensesModel mj_objectArrayWithKeyValuesArray:[self.dbMgr getAllTuplesFromTabel:inuse_income_expenses_table andSearchModel:[HDJDSQLSearchModel createSQLSearchModelWithAttriName:@"type_id" andSymbol:@"=" andSpecificValue:[NSString stringWithFormat:@"%ld",self.type]]]]];
        DLog(@"%ld",_itemsArr.count);
        [self.dbMgr.database close];
        
    }
    return _itemsArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNav];
    
    self.tableView.hidden = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuse_id = @"cateCell";
    HDJIncomeExpensesModel* model = self.itemsArr[indexPath.row];
    HDJTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    if (!cell) {
        cell = [[HDJTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse_id];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.iconImageView.image = [UIImage imageNamed:model.icon];
    cell.titleLabel.text = model.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDJIncomeExpensesModel* model = self.itemsArr[indexPath.row];
    HDJAddCategoryController* next = [HDJAddCategoryController new];
    next.type = self.type;
    next.isEdit = YES;
    next.editModel = model;
    [self.navigationController pushViewController:next animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        HDJIncomeExpensesModel* model = self.itemsArr[indexPath.row];
        [self.dbMgr.database open];
        [self.dbMgr deleteDataFromTabel:inuse_income_expenses_table andSearchModel:[HDJDSQLSearchModel createSQLSearchModelWithAttriName:@"cate_id" andSymbol:@"=" andSpecificValue:[NSString stringWithFormat:@"%ld",model.cate_id]]];
        [self.dbMgr.database close];

        [self.itemsArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

removeCellSeparator

- (void)initNav{
    self.navTitle = @"编辑分类";
    
    self.view.backgroundColor = WHITE_COLOR;
    self.navButtonLeft.frame = CGRectMake(0, 0, NavigationBarIcon + NAVIGATIONBAR_HEIGHT, NAVIGATIONBAR_HEIGHT);
    [self.navButtonLeft setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [self.navButtonLeft setTitle:@"" forState:UIControlStateNormal];
    
    [self.navButtonRight setTitle:@"添加" forState:UIControlStateNormal];
}

- (void)navRightPressed:(id)sender {
    DLog(@"=> navRightPressed !");
    HDJAddCategoryController* next = [HDJAddCategoryController new];
    next.type = self.type;
    next.isEdit = NO;
    [self.navigationController pushViewController:next animated:YES];
}

@end

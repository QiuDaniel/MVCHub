//
//  LanguageViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "LanguageViewController.h"

@interface LanguageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *languageTabelView;
@property (nonatomic, copy) NSArray *sectionIndexTitles, *dataSource;

@end

@implementation LanguageViewController

#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.item = params[@"language"];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Language";
    [self.view addSubview:self.languageTabelView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sectionIndexTitles = [self sectionIndexTitlesWithItems:[self fetchLocalData]];
    self.dataSource = [self dataSourceWithItems:[self fetchLocalData]];
    [self.languageTabelView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionIndexTitles ? self.sectionIndexTitles.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section >= self.sectionIndexTitles.count ? nil : self.sectionIndexTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row][@"name"];
    if ([self.item[@"slug"] isEqualToString:self.dataSource[indexPath.section][indexPath.row][@"slug"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.item = self.dataSource[indexPath.section][indexPath.row];
    self.callback(self.dataSource[indexPath.section][indexPath.row]);
    [tableView reloadData];
}

#pragma mark - Private Method
- (NSArray *)fetchLocalData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[self resourceName] ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    NSArray *items = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error) {
        DebugLogError(error);
        return nil;
    }
    
    return items;
}

- (NSArray *)sectionIndexTitlesWithItems:(NSArray *)items {
    if (items.count == 0) return nil;
    NSArray *firstLetters = [items.rac_sequence map:^(NSDictionary *item) {
        return [item[@"name"] firstLetter];
    }].array;
    
    return [[NSSet setWithArray:firstLetters].rac_sequence.array sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}

- (NSArray *)dataSourceWithItems:(NSArray *)items {
    return [[[items.rac_sequence.signal groupBy:^(NSDictionary *item) {
        return [item[@"name"] firstLetter];
    }] map:^(RACSignal *signal) {
        return signal.sequence;
    }].sequence map:^(RACSequence *sequence) {
        return sequence.array;
    }].array;
}


#pragma mark - Getter
- (UITableView *)languageTabelView {
    if (!_languageTabelView) {
        _languageTabelView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.sectionIndexColor = [UIColor darkGrayColor];
            tableView.sectionIndexBackgroundColor = [UIColor clearColor];
            tableView.sectionIndexMinimumDisplayRowCount = 20;
            {
                UIEdgeInsets insets = UIEdgeInsetsMake(64, 0, 0, 0);
                tableView.contentInset = insets;
            }
            tableView;
        });
    }
    return _languageTabelView;
}

- (NSString *)resourceName {
    return @"Languages";
}
@end

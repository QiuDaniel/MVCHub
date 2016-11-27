//
//  SelectBranchOrTagViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/5.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "SelectBranchOrTagViewController.h"

@interface SelectBranchOrTagViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *references;
@property (nonatomic, strong) OCTRef *selectedReference;

@end

@implementation SelectBranchOrTagViewController

#pragma mark - Init

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.references = params[@"references"];
        self.selectedReference = params[@"selectedReference"];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Select Branch or Tag";
    [self setupNavBtn];
    [self changeReferencesFormat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.callback) {
        self.callback(self.references[indexPath.row][@"reference"]);
    }
    [self backToParentVC];
}

#pragma mark - TableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.references.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSDictionary *dictionary = (NSDictionary *)self.references[indexPath.row];
    cell.imageView.image = [UIImage octicon_imageWithIcon:dictionary[@"identifier"]
                                          backgroundColor:[UIColor clearColor]
                                                iconColor:[UIColor darkGrayColor]
                                                iconScale:1
                                                  andSize:kLeftImageSize];
    cell.textLabel.text = dictionary[@"name"];
    if ([[dictionary[@"reference"] name] isEqualToString:self.selectedReference.name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Response Event
- (void)backToParentVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Overwritten Method
- (void)setupNavBtn {
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backToParentVC)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

#pragma mark - PrivateMethod
- (void)changeReferencesFormat {
    self.references = [[self.references.rac_sequence filter:^BOOL(OCTRef *reference) {
        return [reference.name componentsSeparatedByString:@"/"].count == 3;
    }] map:^id(OCTRef *reference) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:reference forKey:@"reference"];
        
        [dictionary setValue:[reference.name componentsSeparatedByString:@"/"].lastObject forKey:@"name"];
        [dictionary setValue:reference.octiconIdentifier forKey:@"identifier"];
        
        return dictionary.copy;
    }].array;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tintColor = [UIColor colorWithHexString:@"0x4183C4"];
    }
    return _tableView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

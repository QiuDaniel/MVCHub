//
//  GitTreeViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/5.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "GitTreeViewController.h"

@interface GitTreeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *gitTreeTableView;
@property (nonatomic, copy) NSArray *gitTreeArr;

@property (nonatomic, strong) OCTRepository *repository;
@property (nonatomic, strong) OCTRef *reference;

@property (nonatomic, strong, readwrite) OCTTree *tree;
@property (nonatomic, strong, readwrite) NSString *path;

@end

@implementation GitTreeViewController

#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.path = params[@"path"];
        self.tree = params[@"tree"];
        self.repository = params[@"repository"];
        self.reference = params[@"reference"];
        
        self.titleViewType = TitleViewTypeDoubleTitle;
       
        
        if (self.path.length == 0) {
            [[MVCHubAPIManager sharedManager] requestGitTreeCacheForReference:self.reference.name inRepository:self.repository andBlock:^(id data, NSError *error) {
                if (data) {
                    self.tree = [MTLJSONAdapter modelOfClass:[OCTTree class] fromJSONDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] error:nil];
                    DebugLog(@"tree====>%@",self.tree);
                }
            }];
            
        }
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.gitTreeTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.doubleTitleView.titleLabel.text = self.repository.name;
    self.doubleTitleView.subtitleLabel.text = self.repository.ownerLogin;
    if (self.path.length == 0 && self.tree == nil) {
        [self requestGitTree];
    } else if (self.tree) {
        [self setGitTreeObjectToArray];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelgate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OCTTreeEntry *treeEntry = self.gitTreeArr[indexPath.row][@"treeEntry"];
    
    if (treeEntry.type == OCTTreeEntryTypeTree) {
        GitTreeViewController *gitTreeVC = [[GitTreeViewController alloc] initWithParams:@{
                                                                                          @"path":treeEntry.path ?:@"",
                                                                                          @"tree":self.tree ?: [NSNull null],
                                                                                          @"repository": self.repository ?: [NSNull null],
                                                                                          @"reference":self.reference ?: [NSNull null]
                                                                                          }];
        [self.navigationController pushViewController:gitTreeVC animated:YES];
    } else if (treeEntry.type == OCTTreeEntryTypeBlob) {
    
    }
}


#pragma mark - TableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gitTreeArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSDictionary *dictionary = (NSDictionary *)self.gitTreeArr[indexPath.row];
    cell.imageView.image = [UIImage octicon_imageWithIcon:dictionary[@"identifier"]
                                          backgroundColor:[UIColor clearColor]
                                                iconColor:[UIColor colorWithHexString:dictionary[@"hexRGB"]]
                                                iconScale:1
                                                  andSize:kLeftImageSize];
    cell.textLabel.text = dictionary[@"text"];
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.text = dictionary[@"detailText"];
    detailLabel.textColor = [UIColor colorWithHexString:@"0x8e8e93"];
    [detailLabel sizeToFit];
    cell.accessoryView = detailLabel;
    
    return cell;
}

#pragma mark - Private Methods
- (void)setGitTreeObjectToArray {
        @weakify(self)
        self.gitTreeArr = [[self.tree.entries.rac_sequence
                           filter:^(OCTTreeEntry *treeEntry) {
                               return @(treeEntry.type != OCTTreeEntryTypeCommit).boolValue;
                           }]
                          filter:^(OCTTreeEntry *treeEntry) {
                              @strongify(self)
                              
                              if (self.path.length == 0) {
                                  return @([treeEntry.path componentsSeparatedByString:@"/"].count == 1).boolValue;
                              } else {
                                  return @([treeEntry.path hasPrefix:[self.path stringByAppendingString:@"/"]] &&
                                  [treeEntry.path componentsSeparatedByString:@"/"].count == [self.path componentsSeparatedByString:@"/"].count + 1).boolValue;
                              }
                          }].array;
        
        self.gitTreeArr = [self.gitTreeArr sortedArrayUsingComparator:^(OCTTreeEntry *treeEntry1, OCTTreeEntry *treeEntry2) {
            if (treeEntry1.type == treeEntry2.type) {
                return [treeEntry1.path caseInsensitiveCompare:treeEntry2.path];
            } else {
                return treeEntry1.type == OCTTreeEntryTypeTree ? NSOrderedAscending : NSOrderedDescending;
            }
        }];
        
        self.gitTreeArr = [self.gitTreeArr.rac_sequence map:^(OCTTreeEntry *treeEntry) {
            NSMutableDictionary *output = @{
                                            @"treeEntry": treeEntry ?: [NSNull null],
                                            @"identifier": treeEntry.type == OCTTreeEntryTypeTree ? @"FileDirectory" : @"FileText",
                                            @"hexRGB": treeEntry.type == OCTTreeEntryTypeTree ? @"0x80a6cd" : @"0x777777",
                                            @"text": [treeEntry.path componentsSeparatedByString:@"/"].lastObject ?: @"",
                                            }.mutableCopy;
            
            if (treeEntry.type == OCTTreeEntryTypeBlob) {
                OCTBlobTreeEntry *blobEntry = (OCTBlobTreeEntry *)treeEntry;
                
                NSString *size = nil;
                if (blobEntry.size >= 1024 * 1024 * 1024) {
                    size = [NSString stringWithFormat:@"%.2f G", blobEntry.size / (1024.0 * 1024 * 1024)];
                } else if (blobEntry.size >= 1024 * 1024) {
                    size = [NSString stringWithFormat:@"%.2f M", blobEntry.size / (1024.0 * 1024)];
                } else if (blobEntry.size >= 1024) {
                    size = [NSString stringWithFormat:@"%.2f KB", blobEntry.size / 1024.0];
                } else {
                    size = [NSString stringWithFormat:@"%@ B", @(blobEntry.size)];
                }
                
                [output setValue:size forKey:@"detailText"];
            } else {
                NSArray *entries = [[self.tree.entries.rac_sequence
                                     filter:^(OCTTreeEntry *treeEntry) {
                                         return @(treeEntry.type != OCTTreeEntryTypeCommit).boolValue;
                                     }]
                                    filter:^(OCTTreeEntry *treeEntry2) {
                                        return @([treeEntry2.path hasPrefix:[treeEntry.path stringByAppendingString:@"/"]] &&
                                        [treeEntry2.path componentsSeparatedByString:@"/"].count == [treeEntry.path componentsSeparatedByString:@"/"].count + 1).boolValue;
                                    }].array;
                
                [output setValue:@(entries.count).stringValue forKey:@"detailText"];
            }
            
            return output.copy;
        }].array;
    
    [self.gitTreeTableView reloadData];
}

#pragma mark - API Request
- (void)requestGitTree {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = kMBProgressHUD_Lable_Text;
    [[MVCHubAPIManager sharedManager] requestGitTreeForReference:[[self.reference.name componentsSeparatedByString:@"/"] lastObject] inRepository:self.repository andBlock:^(id data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        if (data) {
            self.tree = (OCTTree *)data;
            [self setGitTreeObjectToArray];
        }
    }];
}

#pragma mark - Getter
- (UITableView *)gitTreeTableView {
    if (!_gitTreeTableView) {
        _gitTreeTableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
        _gitTreeTableView.delegate = self;
        _gitTreeTableView.dataSource = self;
    }
    return _gitTreeTableView;
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

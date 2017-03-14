//
//  ViewController.m
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import "ViewController.h"
#import "MGPlayerViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MGVideo";
    
    self.items = [NSMutableArray array];
    [self.items addObject:@"http://videoplayer.babytreeimg.com/2017/0310/llfjkp_gxlhd0uNKXXYG1dX55_IU.mp4"];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MGPlayerViewController *playerViewController = [[MGPlayerViewController alloc]initWithVideoURL:[NSURL URLWithString:self.items[indexPath.row]]];
    [self.navigationController presentViewController:playerViewController animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [UITableViewCell new];
    }
    
    NSString *urlString = self.items[indexPath.row];
    cell.textLabel.text = urlString;
    return cell;
}

@end


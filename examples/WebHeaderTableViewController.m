//
//  WebHeaderTableViewController.m
//  CC3DPerspectiveAnimationHeaderTableView
//
//  Created by caesar_cat (SHIGETA Takuji)
//    Twitter: @caeasr_cat
//    GitHub : https://github.com/caesarcat
//  Copyright (c) 2015 caesar_cat. All rights reserved.
//

#import "WebHeaderTableViewController.h"
#import "CC3DPerspectiveAnimationHeaderTableView.h"

@interface WebHeaderTableViewController ()
@property (nonatomic, strong) NSArray *images;

@end

@implementation WebHeaderTableViewController

#pragma mark - View lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"json"];
    self.images = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Actions

- (void)rightBarButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_contentInfo[@"link"]]];
}


#pragma mark - Accessor methods

- (void)setContentInfo:(NSDictionary *)contentInfo {
    @synchronized(self) {
        _contentInfo = contentInfo;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Safariで開く" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    NSDictionary *imageInfo = _images[indexPath.row];
    // title
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    titleLabel.text = imageInfo[@"title"];
    // url
    UILabel *linkLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    linkLabel.text = imageInfo[@"link"];
    // thumbnail
    UIImageView *thumbnailView = (UIImageView *)[cell.contentView viewWithTag:1001];
    // request thumbnail data
    NSURL *url = [NSURL URLWithString:imageInfo[@"url"]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0] queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   thumbnailView.image = [UIImage imageWithData:data];
                               });
                           }];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebHeaderTableViewController *nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebHeaderTableViewController"];
    nextViewController.contentInfo = _images[indexPath.row];

    NSDictionary *imageInfo = _images[indexPath.row];
    CC3DPerspectiveAnimationHeaderTableView *nextTableView = (CC3DPerspectiveAnimationHeaderTableView *)nextViewController.tableView;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, self.view.bounds.size.height)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageInfo[@"link"]]]];
    nextTableView.perspectiveView = webView;

    [self.navigationController pushViewController:nextViewController animated:YES];
}


@end

//
//  VideoHeaderTableViewController.m
//  CC3DPerspectiveAnimationHeaderTableView
//
//  Created by caesar_cat (SHIGETA Takuji)
//    Twitter: @caeasr_cat
//    GitHub : https://github.com/caesarcat
//  Copyright (c) 2015 caesar_cat. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VideoHeaderTableViewController.h"
#import "CC3DPerspectiveAnimationHeaderTableView.h"


@interface VideoHeaderTableViewController ()
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) VideoHeaderTableViewController *nextViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlViewVerticalSpaceConstraint;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet CC3DPerspectiveAnimationHeaderTableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation VideoHeaderTableViewController


#pragma mark - View lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"videos" ofType:@"json"];
    self.videos = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
    self.tableView.tableHeaderView.frame = CGRectZero;
    self.controlViewVerticalSpaceConstraint.constant = -90.f;
    [self.indicatorView startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Actions

- (IBAction)playPauseAction:(UIButton *)sender {
    if (_player.rate == 1.f) {
        [_player pause];
        sender.selected = NO;
    } else {
        if (CMTimeGetSeconds(_player.currentTime) == CMTimeGetSeconds(_player.currentItem.duration)) {
            [_player seekToTime:CMTimeMake(0.f, _player.currentTime.timescale) completionHandler:^(BOOL finished) {
                [_player play];
            }];
        } else {
            [_player play];
        }
        sender.selected = YES;
    }
}

- (IBAction)openAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_contentInfo[@"link"]]];
}

- (IBAction)closeAction:(id)sender {
    [self close];
}


#pragma mark - Private methods

- (void)close {
    [self.player pause];
    [UIView animateWithDuration:0.5f animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0.f, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (nil != _closeHandler) {
            _closeHandler();
        }
    }];
}

- (void)rightBarButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_contentInfo[@"link"]]];
}


#pragma mark - Accessor methods

- (void)setContentInfo:(NSDictionary *)contentInfo {
    @synchronized(self) {
        _contentInfo = contentInfo;

        // Resize tableHeaderView fullscreen.
        self.tableView.tableHeaderView.frame = self.view.bounds;

        NSURL *url = [NSURL URLWithString:_contentInfo[@"url"]];
        // Set Video to perspectiveView.
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
        self.player = [AVPlayer playerWithPlayerItem:item];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.view.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

        _tableView.perspectiveView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_tableView.perspectiveView.layer insertSublayer:self.playerLayer atIndex:0];

        [_player play];
        _titleLabel.text = _contentInfo[@"title"];
        [_tableView.perspectiveView bringSubviewToFront:_titleLabel];
        [_indicatorView stopAnimating];
    }
}


#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // -60までスクロールすれば自身のビューを隠して破棄する。
    if (scrollView.contentOffset.y < -60.f) {
        self.tableView.scrollEnabled = NO;
        if (nil == self.tableView.perspectiveView) {
            // perspectiveViewが無ければ閉じる
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self close];
        }
        return;
    }
    // このへんは演出。
    else if (scrollView.contentOffset.y > 130.f) {
        _controlViewVerticalSpaceConstraint.constant = scrollView.contentOffset.y;
    } else {
        _controlViewVerticalSpaceConstraint.constant = scrollView.contentOffset.y + (scrollView.contentOffset.y - 130.f);
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    NSDictionary *videoInfo = _videos[indexPath.row];
    // title
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    titleLabel.text = videoInfo[@"title"];
    // url
    UILabel *linkLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    linkLabel.text = videoInfo[@"link"];
    // thumbnail
    UIImageView *thumbnailView = (UIImageView *)[cell.contentView viewWithTag:1001];
    // request thumbnail data
    NSURL *url = [NSURL URLWithString:videoInfo[@"thumbnail-url"]];
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
    if (self.nextViewController) return;
    self.nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoHeaderTableViewController"];
    _nextViewController.contentInfo = _videos[indexPath.row];
    _nextViewController.view.center = self.view.center;
    _nextViewController.view.transform = CGAffineTransformMakeScale(0.f, 0.f);
    _nextViewController.view.alpha = 0.f;
    _nextViewController.closeHandler = ^{
        _nextViewController = nil;
    };
    [self.view addSubview:_nextViewController.view];
    __weak __typeof(self) wself = self;
    [UIView animateWithDuration:0.4f animations:^{
        wself.nextViewController.view.transform = CGAffineTransformIdentity;
        wself.nextViewController.view.alpha = 1.f;
    } completion:^(BOOL finished) {
        [wself.player pause];
    }];
}

@end

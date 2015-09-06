//
//  CC3DPerspectiveAnimationHeaderTableView.m
//  CC3DPerspectiveAnimationHeaderTableView
//
//  Created by caesar_cat (SHIGETA Takuji)
//    Twitter: @caeasr_cat
//    GitHub : https://github.com/caesarcat
//  Copyright (c) 2015 caesar_cat. All rights reserved.
//

#import "CC3DPerspectiveAnimationHeaderTableView.h"

@implementation CC3DPerspectiveAnimationHeaderTableView


#pragma mark - Inheritance methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    self.tableHeaderView.backgroundColor = [UIColor blackColor];
    self.tableHeaderView.clipsToBounds = YES;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}


#pragma mark - Accessor methods

- (void)setPerspectiveView:(UIView *)perspectiveView {
    @synchronized(self) {
        if (nil == self.tableHeaderView) {
            UIView *tableHeaderView = [[UIView alloc] initWithFrame:self.frame];
            self.tableHeaderView = tableHeaderView;
        }
        self.tableHeaderView.backgroundColor = [UIColor blackColor];
        self.tableHeaderView.clipsToBounds = YES;
        
        _perspectiveView = perspectiveView;
        _perspectiveView.clipsToBounds = YES;
        [self.tableHeaderView insertSubview:_perspectiveView atIndex:0];
        self.tableHeaderView.frame = _perspectiveView.bounds;
    }
}


#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [(NSValue *)change[@"new"] CGPointValue];
        float percentage = (contentOffset.y / 3) / self.frame.size.height;
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = (- 1.f / 80.f) * percentage;
        transform = CATransform3DRotate(transform, M_PI_4 * percentage, contentOffset.y, 0.f, 0.f);
        transform = CATransform3DScale(transform, 1-percentage*2, 1-percentage*2, 1-percentage*2);
        transform = CATransform3DTranslate(transform, 0.f, contentOffset.y * (0.2f + percentage * 5), -100.f);
        self.perspectiveView.layer.transform = transform;
    }
}

@end

//
//  VideoHeaderTableViewController.h
//  CC3DPerspectiveAnimationHeaderTableView
//
//  Created by caesar_cat (SHIGETA Takuji)
//    Twitter: @caeasr_cat
//    GitHub : https://github.com/caesarcat
//  Copyright (c) 2015 caesar_cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ CloseHandler)();

@interface VideoHeaderTableViewController : UIViewController

@property (nonatomic, strong) NSDictionary *contentInfo;
@property (nonatomic, copy) CloseHandler closeHandler;

@end

# CC3DPerspectiveAnimationHeaderTableView
CC3DPerspectiveAnimationHeaderTableView is a UITableView which implemented 3D perspective animation header.

ScreenCast
-----
![](https://github.com/caesarcat/CC3DPerspectiveAnimationHeaderTableView/blob/master/sample1.gif)

Features
-----
- 3D Perspective animation view is easy customize. Add an instance of your custom View to instance of "tableView.perspectiveView".
- Custom views can be any kind of view . For example ImageView, AVPlayerLayer, WebView .. etc.


HowTo
-----
- Set the "CC3DPerspectiveAnimationHeaderTableView" class for your tableView superclass in Storyboard.
- Set "perspectiveView" property.
```
- (void)viewDidLoad {
    [super viewDidLoad];
    CC3DPerspectiveAnimationHeaderTableView *tableView = (CC3DPerspectiveAnimationHeaderTableView *)self.tableView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"picture.jpg"];
    tableView.perspectiveView = imageView;
}
```
- Build and Run!


Requirements
-----
- iOS 7.0+
- Xcode 6.x


Example project
-----
Launch CC3DPerspectiveAnimationHeaderTableView.xcodeproj. Try sevral demonstrations.

All cat images, videos, web contents  were provided by qnote Inc.
Please like and follow our accounts.
- Facebook: https://fb.me/qnote.inc
- Twitter:  https://twitter.com/qnote_inc

License
-----
CC3DPerspectiveAnimationHeaderTableView is released under the MIT license. See LICENSE for details.

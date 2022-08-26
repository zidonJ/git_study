//
//  ViewController.h
//  test
//
//  Created by jiangzedong on 2020/11/30.
//

#import <UIKit/UIKit.h>

@interface ABCD : NSObject
{
    @public
    NSString *_testPublic;
}
- (void)myLog:(NSString *)str;

@end

@interface MYTabVC : UITabBarController

@end

@interface MyNavViewController : UINavigationController

@end

@interface ViewController : UIViewController


@end


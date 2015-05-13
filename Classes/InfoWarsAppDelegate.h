//
//  InfoWarsAppDelegate.h
//  InfoWars
//
//  Created by Imthiaz Rafiq @hmimthiaz
//  http://imthi.com
//  https://github.com/hmimthiaz/InfoWars
//


#import <UIKit/UIKit.h>

@interface InfoWarsAppDelegate : NSObject <UIApplicationDelegate> {
    UITabBarController * _tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) UITabBarController * tabBarController;

@end

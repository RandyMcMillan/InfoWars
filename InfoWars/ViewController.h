//
//  ViewController.h
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <UIWebViewDelegate>

@property (strong)UIWebView * listenNowWebView;

- (IBAction)playVideoStream:(id)sender;
- (IBAction)playAudioStream:(id)sender;

@end

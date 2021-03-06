//
//  iPhoneStreamingPlayerViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import "AudioToolbox/AudioToolbox.h"
#import "DataObject.h"

@class AudioStreamer, LevelMeterView;

@interface NowPlayingViewController : UIViewController <UIWebViewDelegate>
{
	IBOutlet UITextField	*downloadSourceField;
	IBOutlet UIButton		*button;
	IBOutlet UIView			*volumeSlider;
	IBOutlet UILabel		*positionLabel;
	IBOutlet UISlider		*progressSlider;
	IBOutlet UITextField	*metadataArtist;
	IBOutlet UITextField	*metadataTitle;
	IBOutlet UITextField	*metadataAlbum;
	IBOutlet UIButton		*callButton;
	IBOutlet UIButton		*emailButton;

	IBOutlet UILabel	*phoneLabel;
	IBOutlet UIView		*mainView;

	AudioStreamer	*streamer;
	NSTimer			*progressUpdateTimer;
	NSTimer			*levelMeterUpdateTimer;
	LevelMeterView	*levelMeterView;
	NSString		*currentArtist;
	NSString		*currentTitle;
	NSString		*currentChannel;
	NSArray			*channelList;
    
    DataObject    *dataObject;
    
}

@property (nonatomic, retain) UIWebView *listenNowWebView;
@property (nonatomic, retain) UIWebView *pageWebView;
@property (nonatomic, retain) UIView	*pageWebViewContainer;
@property (nonatomic, retain) DataObject	*dataObject;

- (IBAction)playVideoStream:(id)sender;
- (IBAction)showPodCastList:(id)sender;
- (IBAction)stopAudioStream:(id)sender;
- (IBAction)loadWebPage:(id)sender;

- (void)assignURL:(DataObject *)object;

- (void)loadWebPage;
- (void)playAudioStream;

- (IBAction)cancel:(id)sender;

@property (retain) NSString				*currentArtist;
@property (retain) NSString				*currentTitle;
@property (retain, nonatomic) NSArray	*channelList;
@property (retain, nonatomic) NSString	*currentChannel;

// @property (nonatomic) BOOL uiIsVisible;

- (IBAction)buttonPressed:(id)sender;
- (void)spinButton;
- (void)forceUIUpdate;
- (void)createTimers:(BOOL)create;
- (void)playbackStateChanged:(NSNotification *)aNotification;
- (void)updateProgress:(NSTimer *)updatedTimer;
- (IBAction)sliderMoved:(UISlider *)aSlider;
- (void)changeChannel:(int)channelIndex;


@property (nonatomic, readwrite) NSString	*movieURLString;

@end

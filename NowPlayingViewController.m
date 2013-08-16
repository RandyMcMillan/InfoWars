//
//  iPhoneStreamingPlayerViewController.m
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

#import "AppDelegate.h"
#import "NowPlayingViewController.h"
#import "AudioStreamer.h"
#import "LevelMeterView.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "Reachability.h"

@interface NowPlayingViewController () {
	IBOutlet UIButton					*watchNow;
	IBOutlet UIButton					*listenNow;
	IBOutlet UIWebView					*listenNowWebView;
	IBOutlet UIWebView					*pageWebView;
	IBOutlet UIActivityIndicatorView	*myIndicator;
	IBOutlet UIView						*pageWebViewContainer;
}

@property (nonatomic, readwrite) NSString	*movieURLString;
@property (nonatomic, readwrite) UIButton	*watchNow;
@property (nonatomic, readwrite) UIButton	*listenNow;

@property (strong) UIActivityIndicatorView *myIndicator;

// @property (nonatomic,readwrite) UIWebView *webView;

@end

// http://stream.infowars.com:80

NSString *const HD1_HIGH_QUALITY = @"http://stream.infowars.com:80";
NSString *const HD2 = @"http://stream.infowars.com:80";
NSString *const HD3 = @"http://stream.infowars.com:80";
NSString *const HD4 = @"http://stream.infowars.com:80";

@implementation NowPlayingViewController

@synthesize watchNow, listenNow, listenNowWebView, pageWebView, myIndicator, pageWebViewContainer;
@synthesize currentArtist, currentTitle, channelList, currentChannel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		self.title				= NSLocalizedString(@"NowPlaying", @"NowPlaying");
		self.tabBarItem.image	= [UIImage imageNamed:@"194-note-2"];
	}

	return self;
}

//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];

	if (!image) {
		[button setImage:[UIImage imageNamed:@"playbutton.png"] forState:0];
	} else {
		[button setImage:image forState:0];

		if ([button.currentImage isEqual:[UIImage imageNamed:@"loadingbutton.png"]]) {
			// [self spinButton];
		}
	}
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer) {
		[[NSNotificationCenter defaultCenter]
		removeObserver	:self
		name			:ASStatusChangedNotification
		object			:streamer];
		[self createTimers:NO];

		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

//
// forceUIUpdate
//
// When foregrounded force UI update since we didn't update in the background
//
- (void)forceUIUpdate
{
	if (currentArtist) {
		metadataArtist.text = currentArtist;
	}

	if (currentTitle) {
		metadataTitle.text = currentTitle;
	}

	if (!streamer) {
		[levelMeterView updateMeterWithLeftValue:0.0
						rightValue				:0.0];
		[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	} else {
		[self playbackStateChanged:NULL];
	}
}

//
// createTimers
//
// Creates or destoys the timers
//
- (void)createTimers:(BOOL)create
{
	if (create) {
		if (streamer) {
			[self createTimers:NO];
			progressUpdateTimer =
				[NSTimer
				scheduledTimerWithTimeInterval	:0.1
				target							:self
				selector						:@selector(updateProgress:)
				userInfo						:nil
				repeats							:YES];
			levelMeterUpdateTimer =
				[NSTimer
				scheduledTimerWithTimeInterval	:.1
				target							:self
				selector						:@selector(updateLevelMeters:)
				userInfo						:nil
				repeats							:YES];
		}
	} else {
		if (progressUpdateTimer) {
			[progressUpdateTimer invalidate];
			progressUpdateTimer = nil;
		}

		if (levelMeterUpdateTimer) {
			[levelMeterUpdateTimer invalidate];
			levelMeterUpdateTimer = nil;
		}
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer:(NSString *)urlString
{
	NSLog(@">>> Entering %s <<<", __PRETTY_FUNCTION__);
	self.channelList = [[NSArray alloc] initWithObjects:@"http://stream.infowars.com:80", nil];

	if (streamer) {
		return;
	}

	NSLog(@"1");
	NSLog(@"nowplaing controller id:%@", self);
	[self destroyStreamer];
	NSLog(@"2");

	//	NSString *escapedValue =
	//    [(NSString *)CFURLCreateStringByAddingPercentEscapes(
	//                                                         nil,
	//                                                         (CFStringRef)downloadSourceField.text,
	//                                                         NULL,
	//                                                         NULL,
	//                                                         kCFStringEncodingUTF8)
	//     autorelease];
	NSLog(@"3");
	NSLog(@"channel list = %@", self.channelList);
	NSLog(@"channel index = %@", self.currentChannel);
	// NSString *urlString = [self.channelList objectAtIndex:[self.currentChannel intValue]];
	NSLog(@"url string = %@", urlString);
	NSLog(@"4");
	NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
			nil,
			(CFStringRef)urlString,
			NULL,
			NULL,
			kCFStringEncodingUTF8)
		autorelease];

	NSLog(@"5");

	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];

	[self createTimers:YES];
	NSLog(@"6 ");

	[[NSNotificationCenter defaultCenter]
	addObserver :self
	selector	:@selector(playbackStateChanged:)
	name		:ASStatusChangedNotification
	object		:streamer];
#ifdef SHOUTCAST_METADATA
		[[NSNotificationCenter defaultCenter]
		addObserver :self
		selector	:@selector(metadataChanged:)
		name		:ASUpdateMetadataNotification
		object		:streamer];
#endif
	NSLog(@">>> Leaving %s <<<", __PRETTY_FUNCTION__);
}

// Creates the volume slider, sets the default path for the local file and
// creates the streamer immediately if we already have a file at the local
// location.
- (void)viewDidLoad
{
	[super viewDidLoad];

	// self.channelList = [[NSArray alloc] initWithObjects:@"http://stream.wmnf.org:8000/wmnf_high_quality",@"http://131.247.176.1:8000/stream",@"http://stream.wmnf.org:8000/wmnf_hd3",@"http://stream.wmnf.org:8000/wmnf_hd4", nil];
	self.channelList	= [[NSArray alloc] initWithObjects:@"http://stream.infowars.com:80", nil];
	currentChannel		= 0;

	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];

	[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];

	// levelMeterView = [[LevelMeterView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.0, self.view.frame.size.height*0.90, 300, 5.0)];
	levelMeterView = [[LevelMeterView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.0, self.view.frame.size.height * 0.0, 300, 5.0)];
	levelMeterView.autoresizingMask = (
		// UIViewAutoresizingFlexibleBottomMargin |
		// UIViewAutoresizingFlexibleLeftMargin |
		// UIViewAutoresizingFlexibleTopMargin |
		// UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleWidth
		);

	[levelMeterView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:levelMeterView];

	NSError *setCategoryErr = nil;
	// NSError *activationErr  = nil;
	[[AVAudioSession sharedInstance]
	setCategory :AVAudioSessionCategoryPlayback
	error		:&setCategoryErr];
	//    [[AVAudioSessionsharedInstance]
	//     setActive: YES
	//     error: &activationErr];'

	[self startReach];

	self.pageWebView.userInteractionEnabled = FALSE;

	self.myIndicator.alpha = 0.0;
	[self.myIndicator stopAnimating];
	[self loadWebPage];

	[self buttonPressed];
    
    for (UIView *view in [[[self.pageWebView subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	UIApplication *application = [UIApplication sharedApplication];

	if ([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)]) {
		[application beginReceivingRemoteControlEvents];
	}

	[self becomeFirstResponder];	// this enables listening for events
									// update the UI in case we were in the background
	NSNotification *notification =
		[NSNotification
		notificationWithName:ASStatusChangedNotification
		object				:self];
	[[NSNotificationCenter defaultCenter]
	postNotification:notification];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint	= CGPointMake(0.5, 0.5);
	button.layer.position		= CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];

	CABasicAnimation *animation;
	animation					= [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue			= [NSNumber numberWithFloat:0.0];
	animation.toValue			= [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction	= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.delegate			= self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];

	[CATransaction commit];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished) {
		// [self spinButton];
	}
}

//
// buttonspin:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)buttonPressed:(id)sender
{
	[self buttonPressed];
}

- (void)buttonPressed
{
	if ([button.currentImage isEqual:[UIImage imageNamed:@"playbutton.png"]] || [button.currentImage isEqual:[UIImage imageNamed:@"pausebutton.png"]]) {
		[downloadSourceField resignFirstResponder];

		// [self createStreamer];
		[self createStreamer:[channelList objectAtIndex:[currentChannel intValue]]];

		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		[streamer start];
	} else {
		[streamer stop];
	}
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration) {
		double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	if ([streamer isWaiting]) {
		if (appDelegate.uiIsVisible) {
			[levelMeterView updateMeterWithLeftValue:0.0
							rightValue				:0.0];
			[streamer setMeteringEnabled:NO];
			[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		}
	} else if ([streamer isPlaying]) {
		if (appDelegate.uiIsVisible) {
			[streamer setMeteringEnabled:YES];
			[self setButtonImage:[UIImage imageNamed:@"stopbutton.png"]];
		}
	} else if ([streamer isPaused]) {
		if (appDelegate.uiIsVisible) {
			[levelMeterView updateMeterWithLeftValue:0.0
							rightValue				:0.0];
			[streamer setMeteringEnabled:NO];
			[self setButtonImage:[UIImage imageNamed:@"pausebutton.png"]];
		}
	} else if ([streamer isIdle]) {
		if (appDelegate.uiIsVisible) {
			[levelMeterView updateMeterWithLeftValue:0.0
							rightValue				:0.0];
			[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
		}

		[self destroyStreamer];
	}
}

#ifdef SHOUTCAST_METADATA

/** Example metadata
 *
 *   StreamTitle='Kim Sozzi / Amuka / Livvi Franc - Secret Love / It's Over / Automatik',
 *   StreamUrl='&artist=Kim%20Sozzi%20%2F%20Amuka%20%2F%20Livvi%20Franc&title=Secret%20Love%20%2F%20It%27s%20Over%20%2F%20Automatik&album=&duration=1133453&songtype=S&overlay=no&buycd=&website=&picture=',
 *
 *   Format is generally "Artist hypen Title" although servers may deliver only one. This code assumes 1 field is artist.
 */
	- (void)metadataChanged:(NSNotification *)aNotification
	{
		NSString	*streamArtist;
		NSString	*streamTitle;
		NSString	*streamAlbum;
		// NSLog(@"Raw meta data = %@", [[aNotification userInfo] objectForKey:@"metadata"]);

		NSArray				*metaParts = [[[aNotification userInfo] objectForKey:@"metadata"] componentsSeparatedByString:@";"];
		NSString			*item;
		NSMutableDictionary *hash = [[NSMutableDictionary alloc] init];

		for (item in metaParts) {
			// split the key/value pair
			NSArray *pair = [item componentsSeparatedByString:@"="];

			// don't bother with bad metadata
			if ([pair count] == 2) {
				[hash setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
			}
		}

		// do something with the StreamTitle
		NSString *streamString = [[hash objectForKey:@"StreamTitle"] stringByReplacingOccurrencesOfString:@"'" withString:@""];

		NSArray *streamParts = [streamString componentsSeparatedByString:@" - "];

		if ([streamParts count] > 0) {
			streamArtist = [streamParts objectAtIndex:0];
		} else {
			streamArtist = @"";
		}

		// this looks odd but not every server will have all artist hyphen title
		if ([streamParts count] >= 2) {
			streamTitle = [streamParts objectAtIndex:1];

			if ([streamParts count] >= 3) {
				streamAlbum = [streamParts objectAtIndex:2];
			} else {
				streamAlbum = @"";
			}
		} else {
			streamTitle = @"";
			streamAlbum = @"";
		}

		NSLog(@"%@ by %@ from %@", streamTitle, streamArtist, streamAlbum);

		// only update the UI if in foreground
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

		if (appDelegate.uiIsVisible) {
			metadataArtist.text = streamArtist;
			metadataTitle.text	= streamTitle;
			metadataAlbum.text	= streamAlbum;
		}

		self.currentArtist	= streamArtist;
		self.currentTitle	= streamTitle;
	}
#endif	/* ifdef SHOUTCAST_METADATA */

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0) {
		double	progress	= streamer.progress;
		double	duration	= streamer.duration;

		if (duration > 0) {
			[positionLabel setText:
			[NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
			progress,
			duration]];
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		} else {
			[progressSlider setEnabled:NO];
		}
	} else {
		positionLabel.text = @"Time Played:";
	}
}

//
// updateLevelMeters:
//

- (void)updateLevelMeters:(NSTimer *)timer
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

	if ([streamer isMeteringEnabled] && appDelegate.uiIsVisible) {
		[levelMeterView updateMeterWithLeftValue:[streamer averagePowerForChannel:0]
						rightValue				:[streamer averagePowerForChannel:([streamer numberOfChannels] > 1 ? 1 : 0)]];
	}
}

- (void)changeChannel:(int)channelIndex
{
	NSLog(@">>> Entering %s <<<", __PRETTY_FUNCTION__);
	self.channelList = [[NSArray alloc] initWithObjects:@"http://stream.infowars.com:80", nil];

	[streamer stop];
	[self destroyStreamer];
	// AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	// appDelegate.tabBarController.selectedIndex = 0;
	[self createStreamer:[channelList objectAtIndex:channelIndex]];
	[streamer start];
	switch (channelIndex) {
		case 0:
			callButton.hidden	= NO;
			emailButton.hidden	= NO;
			phoneLabel.hidden	= NO;
			break;

		case 1:
			callButton.hidden	= NO;
			emailButton.hidden	= NO;
			phoneLabel.hidden	= NO;
			break;

		case 2:
			callButton.hidden	= YES;
			emailButton.hidden	= NO;
			phoneLabel.hidden	= NO;
			break;

		case 3:
			callButton.hidden	= YES;
			emailButton.hidden	= NO;
			phoneLabel.hidden	= NO;

		default:
			callButton.hidden	= YES;
			emailButton.hidden	= NO;
			phoneLabel.hidden	= NO;
			break;
	}
	self.currentChannel = [NSString stringWithFormat:@"%d", channelIndex];
	NSLog(@"<<< Leaving %s >>>", __PRETTY_FUNCTION__);
}

//
// textFieldShouldReturn:
// Dismiss the text field when done is pressed
// Parameters:
//    sender - the text field
// returns YES
//
- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	[sender resignFirstResponder];
	[self createStreamer:@""];
	return YES;
}

- (IBAction)callButtonPressed:(id)sender
{
	switch ([currentChannel intValue]) {
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:813-239-9663"]];
			break;

		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:813-974-9285"]];
			break;

		default:
			break;
	}
}

- (IBAction)emailButtonPressed:(id)sender
{
	switch ([currentChannel intValue]) {
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:dj@wmnf.org"]];
			break;

		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:hd2@wmnf.org"]];
			break;

		case 2:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:hd3@wmnf.org"]];
			break;

		case 3:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:hd4@wmnf.org"]];
			break;

		default:
			break;
	}
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:dj@wmnf.org"]];
}

// ********** SCREEN TOUCHED **********
// - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
// {
//     //See if touch was inside the label
//     if (CGRectContainsPoint(phoneLabel.frame, [[[event allTouches] anyObject] locationInView:mainView])) {
//         //Open webpage
//         //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
//         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:813-239-9663"]];
//     }
// }

//
// dealloc
// Releases instance memory.
- (void)dealloc
{
	[self destroyStreamer];
	[self createTimers:NO];
	[levelMeterView release];
	[channelList release], channelList = nil;
	[phoneLabel release];
	[mainView release];
	[super dealloc];
}

#pragma mark Remote Control Events
/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[streamer pause];
			break;

		case UIEventSubtypeRemoteControlPlay:
			[streamer start];
			break;

		case UIEventSubtypeRemoteControlPause:
			[streamer pause];
			break;

		case UIEventSubtypeRemoteControlStop:
			[streamer stop];
			break;

		default:
			break;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"viewWillAppear");
}

/*
 *   - (void)viewDidLoad
 *   {
 *    [super viewDidLoad];
 *    [self startReach];
 *
 *    self.pageWebView.userInteractionEnabled = FALSE;
 *
 *    self.myIndicator.alpha = 0.0;
 *    [self.myIndicator stopAnimating];
 *    [self loadWebPage];
 *    // Do any additional setup after loading the view, typically from a nib.
 *   }
 */

- (IBAction)playVideoStream:(id)sender
{
    
    [streamer stop];

	NSLog(@"playVideoStream");
	self.movieURLString =
		@"http://rightbrainmedia.mpl.miisolutions.net/rightbrainmedia-originpull-2/_definst_/mp4:247daily1/playlist.m3u8";
	[self loadVideo];
}

- (void)loadVideo
{
	NSURL			*url		= [NSURL URLWithString:@""];
	NSURLRequest	*request	= [NSURLRequest requestWithURL:url];

	[self.listenNowWebView loadRequest:request];

	NSURL						*movieURL		= [NSURL URLWithString:self.movieURLString];
	MPMoviePlayerViewController *moviePlayer	=
		[[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
	[self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

- (void)playAudioStream
{
	/*
	 *   self.myIndicator.alpha = 1.0;
	 *   [self.myIndicator startAnimating];
	 *
	 *   NSLog(@"playAudioStream");
	 *
	 *   // NOTE set up if then logic for devices
	 *   // for better control
	 *
	 *   // Reference AudioStream fork for config
	 *   // need to be better support for ipad vs iphone
	 *   // preserve main screen for other user activity
	 *
	 *   NSURL			*url		= [NSURL URLWithString:@"http://www.infowars.com/stream.pls"];
	 *   NSURLRequest	*request	= [NSURLRequest requestWithURL:url];
	 *
	 *   [self.listenNowWebView loadRequest:request];
	 *
	 *   ///for iphone
	 *   // self.movieURLString = @"http://www.infowars.com/stream.pls";
	 *   // [self loadVideo];
	 *
	 *
	 */
	self.movieURLString =
		@"http://www.infowars.com/stream.pls";
	[self loadVideo];
}

- (IBAction)playAudioStream:(id)sender
{
	[self playAudioStream];
}

- (IBAction)stopAudioStream:(id)sender
{
	NSURL			*url		= [NSURL URLWithString:@"http://www.infowars.com/"];
	NSURLRequest	*request	= [NSURLRequest requestWithURL:url];

	[self.listenNowWebView loadRequest:request];
}

- (void)loadWebPage
{
	self.myIndicator.alpha = 1.0;
	[self.myIndicator startAnimating];
	NSURL			*url		= [NSURL URLWithString:@"http://www.infowars.com/"];
	NSURLRequest	*request	= [NSURLRequest requestWithURL:url];

	[self.pageWebView loadRequest:request];
}

- (IBAction)loadWebPage:(id)sender
{
	[self loadWebPage];
	//	NSURL			*url		= [NSURL URLWithString:@"http://www.infowars.com/"];
	// NSURLRequest	*request	= [NSURLRequest requestWithURL:url];

	// [self.pageWebView loadRequest:request];
}

// Further error handling refs
///https://github.com/ardalahmet/UIWebViewHttpStatusCodeHandling/
// UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"webViewDidStartLoad");
	self.myIndicator.hidden = FALSE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (webView == self.pageWebView) {
		[UIWebView	animateWithDuration :3.0
					delay				:0.5
					options				:UIViewAnimationCurveEaseInOut
					animations			:^{
			self.pageWebView.alpha = 1.0;
			self.pageWebViewContainer.alpha = 1.0;
		}

					completion			:^(BOOL finished) {
			self.pageWebView.userInteractionEnabled = TRUE;
		}

		];

		// self.pageWebView.hidden = FALSE;
	}

	NSLog(@"webViewDidFinishLoad");
	self.myIndicator.hidden = TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"webView error %@", error);

	[UIActivityIndicatorView	animateWithDuration :3.0
								delay				:0.5
								options				:UIViewAnimationCurveEaseInOut
								animations			:^{
		self.myIndicator.alpha = 0.0;
	}

								completion			:^(BOOL finished) {
		self.myIndicator.hidden = TRUE;
	}

	];

	//    self.myIndicator.hidden = TRUE;

	/*
	 *   UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:@"Connection error"
	 *                                                     message:@"error" delegate:self
	 *                                                     cancelButtonTitle:@"OK"
	 *                                                     otherButtonTitles:nil];
	 *   [connectionError show];
	 */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {}

- (void)startReach
{
	[[NSNotificationCenter defaultCenter]	addObserver :self
											selector	:@selector(reachabilityChanged:)
											name		:kReachabilityChangedNotification
											object		:nil];

	//	Reachability *rightBrainReach =
	// [Reachability reachabilityWithHostname:@"http://miisolutions.net/rightbrainmedia-originpull-2/_definst_/mp4:247daily1/playlist.m3u8"];

	Reachability *rightBrainReach =
		[Reachability reachabilityWithHostname:@"http://rightbrainmedia.mpl.miisolutions.net/rightbrainmedia-originpull-2/_definst_/mp4:247daily1/playlist.m3u8"];

	NSLog(@"rightBrainReach.isReachable = %@",
		rightBrainReach.isReachable ? @"Yes" : @"No");

	Reachability	*reachWithIntConnection = [Reachability reachabilityForInternetConnection];
	Reachability	*reachWithWIFI			= [Reachability reachabilityForLocalWiFi];

	// Create switches based on this boolean
	// Create switches based on this boolean
	NSLog(@"reachWithIntConnection.isReachableViaWiFi = %@",
		reachWithIntConnection.isReachableViaWiFi ? @"Yes" : @"No");

	NSLog(@"reachWithWIFI.isReachableViaWiFi = %@",
		reachWithWIFI.isReachableViaWiFi ? @"Yes" : @"No");

	Reachability *infoWarsStream =
		[Reachability reachabilityWithHostname:@"http://www.infowars.com/stream.pls"];

	NSLog(@"infoWarsStream.isReachable = %@",
		infoWarsStream.isReachable ? @"Yes" : @"No");

	rightBrainReach.reachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.watchNow setTitle:@"Watch Now" forState:UIControlStateNormal];
			});
	};

	rightBrainReach.unreachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.watchNow setTitle:@"Connect to WIFI" forState:UIControlStateNormal];
			});
	};

	infoWarsStream.reachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.listenNow setTitle:@"Listen Now" forState:UIControlStateNormal];
			});
	};

	infoWarsStream.unreachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.listenNow setTitle:@"Connect to WIFI" forState:UIControlStateNormal];
			});
	};

	[infoWarsStream startNotifier];
	[rightBrainReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note
{
	Reachability *reach = [note object];

	if ([reach isReachable]) {
		[self.watchNow setTitle:@"Watch Now" forState:UIControlStateNormal];
		[self.listenNow setTitle:@"Listen Now" forState:UIControlStateNormal];
	} else {
		[self.watchNow setTitle:@"Watch Now" forState:UIControlStateNormal];
		[self.listenNow setTitle:@"Listen Now" forState:UIControlStateNormal];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {}

@end

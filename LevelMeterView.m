//
//  LevelMeterView.m
//  iPhoneStreamingPlayer
//
//  Created by Carlos Oliva G. on 07-08-10.
//  Copyright 2010 iDev Software. All rights reserved.
//

#import "LevelMeterView.h"

#define kMeterViewFullWidth 520.0//[[UIScreen mainScreen] bounds].size.width///520.0

@implementation LevelMeterView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	[[UIColor whiteColor] set];
	//[@"" drawInRect:CGRectMake(0.0, 10.0, 15.0, 15.0) withFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	//[@"" drawInRect:CGRectMake(0.0, 35.0, 15.0, 15.0) withFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
	CGContextFillRect(context, CGRectMake(0.0, 0.0, kMeterViewFullWidth * leftValue, 1.0));
	CGContextFillRect(context, CGRectMake(0.0, 4.0, kMeterViewFullWidth * rightValue, 1.0));
	CGContextFlush(context);
}


- (void)updateMeterWithLeftValue:(CGFloat)left rightValue:(CGFloat)right {
	leftValue = left;
	rightValue = right;
	[self setNeedsDisplay];
}

- (void)dealloc {
    //[super dealloc];
}


@end

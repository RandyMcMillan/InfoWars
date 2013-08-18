//
//  RSSReader.m
//  ePhysics
//
//  Created by David McMahon on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RSSReader.h"
#import "webViewer.h"
#import "NowPlayingViewController.h"
#define ROW_HEIGHT 160


@implementation RSSReader
@synthesize hasImages,path,activityView,newsTable;

-(IBAction) back:(id)sender{
	
	//[self dismissModalViewControllerAnimated:YES];
}

-(void)viewDidLoad {
	// Add the following line if you want the list to be editable
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
	[activityView startAnimating];

    //self.newsTable.rowHeight = ROW_HEIGHT;

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"_________________NowPlayingViewController____________________");
 
    if ([segue.identifier isEqualToString:@"nowPlaying"]) {
        NSLog(@"_________________NowPlayingViewController____________________");
        UITableViewCell *cell = (UITableViewCell *)sender;
        //NSIndexPath *ip = [self.tableView indexPathForCell:cell];
        //Person *p = [self.people objectAtIndex:ip.row];
        
        NowPlayingViewController  *npvc = (NowPlayingViewController *)segue.destinationViewController;
        //[[stories objectAtIndex: storyIndex] objectForKey: @"guid"];
        //npvc.movieURLString = [[stories objectAtIndex: storyIndex] objectForKey: @"guid"];
        //pdv.person = p;
        
        
    }
    
    
}


//*******************************************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [stories count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	if(hasImages == 1)
		return 95;
	else
		return 125;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView 
							 dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
	
	
    if (cell.textLabel.text == nil) {
        cell = [[UITableViewCell alloc] init];
				 
		CGRect frame;
		frame.origin.x = 10;
		frame.origin.y = 0;
		frame.size.height = 75;
		frame.size.width = 300;
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
		titleLabel.tag = 1;
        titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		[titleLabel setBackgroundColor:[UIColor blackColor]];
		[titleLabel setTextColor:[UIColor blueColor]]; // Foreground color
		[cell.contentView addSubview:titleLabel];
		
		if(hasImages == 0){
		  frame.origin.y += 48;
		  UILabel *summaryLabel = [[UILabel alloc] initWithFrame:frame];
		  summaryLabel.tag = 2;
            summaryLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth);

            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:summaryLabel];
		 
		}
    }
	
	
	
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	UILabel * titleLabel = (UILabel *) [cell.contentView viewWithTag:1];
	//titleLabel.numberOfLines = 0;
	titleLabel.text = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
    if(hasImages  == 0)
	{
	  UILabel * summaryLabel = (UILabel *) [cell.contentView viewWithTag:2];
		summaryLabel.numberOfLines = 44;
        summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
        summaryLabel.text = [[stories objectAtIndex: storyIndex] objectForKey: @"summary"];
		
	}
		
	
	
	// Set up the cell
	//int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	//[cell setText:[[stories objectAtIndex: storyIndex] objectForKey: @"title"]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic

    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

    
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	
	
	
	webViewer *myBrowser = [[webViewer alloc] initWithNibName:nil bundle:nil];
    
    myBrowser.storyLink = [[stories objectAtIndex: storyIndex] objectForKey: @"guid"];
	
	// clean up the link - get rid of spaces, returns, and tabs...
	myBrowser.storyLink = [myBrowser.storyLink stringByReplacingOccurrencesOfString:@" " withString:@""];
	myBrowser.storyLink = [myBrowser.storyLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	myBrowser.storyLink = [myBrowser.storyLink stringByReplacingOccurrencesOfString:@"	" withString:@""];
    
	[self presentViewController:myBrowser animated:YES completion:^{NSLog(@"completion");}];
	
	
	
}

//*******************************************************************************

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[activityView stopAnimating];
	
	if ([stories count] == 0) {
		
		
		
        //        NewsPage = @"http://xml.nfowars.net/Alex.rss";

		//[self parseXMLFileAtURL:path];
		[self parseXMLFileAtURL:@"http://xml.nfowars.net/Alex.rss"];
	}
	
	cellSize = CGSizeMake([newsTable bounds].size.width, 360);
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

//*******************************************************************************
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL {
	stories = [[NSMutableArray alloc] init];
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
    [rssParser parse];
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"guid"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
		
		[stories addObject:[item copy]];
		
	}
	
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"guid"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	[newsTable reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}






@end

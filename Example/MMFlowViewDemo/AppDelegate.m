/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */

//
//  AppDelegate.m
//  FlowView
//
//  Created by Markus Müller on 13.01.12.
//  Copyright (c) 2012 www.isnotnil.com. All rights reserved.
//

#import "AppDelegate.h"
#import "MMFlowView.h"
#import "Item.h"
#import <Quartz/Quartz.h>

@interface AppDelegate ()

- (void)loadItems:(NSString*)aPath withRepresentationType:(NSString*)aRepresentationType;

@end

@implementation AppDelegate
{
	NSMutableArray *_items;
}

- (id)init {
    self = [super init];
    if (self) {
        _items = [ NSMutableArray array ];
    }
    return self;
}

#pragma mark - MMFlowViewDataSource

- (NSUInteger)numberOfItemsInFlowView:(MMFlowView *)aFlowView
{
	return [self countOfItems];
}

- (id<MMFlowViewItem>)flowView:(MMFlowView *)aFlowView itemAtIndex:(NSUInteger)index
{
	return [self objectInItemsAtIndex:index];
}

- (void)flowViewSelectionDidChange:(MMFlowView *)aFlowView
{
	[self.imageBrowserView setSelectionIndexes:[NSIndexSet indexSetWithIndex:aFlowView.selectedIndex]
						  byExtendingSelection:NO ];
	[self.imageBrowserView scrollIndexToVisible:(NSInteger)aFlowView.selectedIndex];
}

- (NSDragOperation)flowView:(MMFlowView *)aFlowView validateDrop:(id<NSDraggingInfo>)info proposedIndex:(NSUInteger)anIndex
{
	return anIndex == NSNotFound ? NSDragOperationNone : NSDragOperationCopy;
}

- (BOOL)flowView:(MMFlowView *)aFlowView acceptDrop:(id<NSDraggingInfo>)info atIndex:(NSUInteger)anIndex
{
	return YES;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[ self loadItems:@"/Library/Desktop Pictures" withRepresentationType:kMMFlowViewURLRepresentationType ];
	// load all the movies
	NSArray * paths = NSSearchPathForDirectoriesInDomains( NSMoviesDirectory, NSUserDomainMask, YES);
	NSString *moviesPath = paths[0];
	[ self loadItems:moviesPath withRepresentationType:kMMFlowViewQTMoviePathRepresentationType ];

	[ self.flowView bind:NSContentArrayBinding
				toObject:self.itemArrayController
			 withKeyPath:@"arrangedObjects"
				 options:nil ];
	[ self.flowView bind:kMMFlowViewSelectedIndexKey
				toObject:self.itemArrayController
			 withKeyPath:@"selectionIndex"
				 options:nil ];
	// turn quicklook on
	[self.flowView setCanControlQuickLookPanel:YES];
	[self.imageBrowserView reloadData ];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

#pragma mark - accesors

- (NSArray*)items
{
	return [_items copy];
}

- (void)setItems:(NSArray *)someItems
{
	if (_items != someItems) {
		_items = [someItems mutableCopy];
	}
}

- (NSUInteger)countOfItems
{
	return [_items count];
}

- (id)objectInItemsAtIndex:(NSUInteger)index
{
	return _items[index];
}

- (NSArray*)itemsAtIndexes:(NSIndexSet *)indexes
{
	return [_items objectsAtIndexes:indexes];
}

- (void)insertObject:(id)object inItemsAtIndex:(NSUInteger)index
{
	[_items insertObject:object atIndex:index];
}

- (void)insertItems:(NSArray *)array atIndexes:(NSIndexSet*)indexes
{
	[_items insertObjects:array atIndexes:indexes];
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)index
{
	[_items removeObjectAtIndex:index];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
	[_items removeObjectsAtIndexes:indexes];
}


#pragma mark - private implementation

- (void)loadItems:(NSString*)aPath withRepresentationType:(NSString*)aRepresentationType
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:aPath isDirectory:&isDirectory];
	
	if ( exists && isDirectory ) {
		NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:aPath]
												  includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
																	 options:NSDirectoryEnumerationSkipsHiddenFiles
																errorHandler:nil ];
		for ( NSURL *url in dirEnumerator ) {
			NSNumber *isItemDirectory = NO;
			[url getResourceValue:&isItemDirectory
							forKey:NSURLIsDirectoryKey
							 error:NULL];
			if ( ![isItemDirectory boolValue] ) {
				[ self insertObject:[Item itemWithURL:url representationType:aRepresentationType]
					 inItemsAtIndex:[self countOfItems]];
			}
		}
	}
}

- (void)loadPDFDocument:(NSURL*)anURL
{
	PDFDocument *document = [[PDFDocument alloc] initWithURL:anURL];

	for (NSUInteger i = 0; i < document.pageCount; ++i) {
		PDFPage *page = [document pageAtIndex:i];
		[self insertObject:[Item itemWithPDFPage:page]
			inItemsAtIndex:[self countOfItems]];
	}
}



#pragma mark - IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [ self countOfItems ];
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
	return [ self objectInItemsAtIndex:index ];
}

#pragma mark - IBActions

- (IBAction)openDocument:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setAllowedFileTypes:@[@"com.adobe.pdf"]];
	[panel beginWithCompletionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			[self loadPDFDocument:[panel URL]];
			[self.flowView reloadContent];
		}
	}];
}

- (IBAction)toggleReflection:(id)sender
{
	BOOL show = [(NSButton*)sender state] == NSOnState;
	self.flowView.showsReflection = show;
	[self.reflectionSlider setHidden:!show];
}

- (IBAction)toggleAngle:(id)sender
{
	self.flowView.stackedAngle = [sender selectedTag];
}

- (IBAction)toggleSpacing:(id)sender
{
	self.flowView.spacing = [sender selectedTag];
}

- (IBAction)reflectionChanged:(NSSlider *)sender
{
	self.flowView.reflectionOffset = -[sender floatValue] / 100.0;
}

@end


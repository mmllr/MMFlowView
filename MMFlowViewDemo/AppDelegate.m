/*
 Copyright (c) 2012, Markus Müller, www.isnotnil.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

@synthesize window;
@synthesize flowView;
@synthesize reflectionSlider;
@synthesize imageBrowserView;
@synthesize itemArrayController;

- (id)init {
    self = [super init];
    if (self) {
        self.items = [ NSMutableArray array ];
    }
    return self;
}

- (void)dealloc
{
	self.itemArrayController = nil;
	self.items = nil;
	self.flowView = nil;
	self.reflectionSlider = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[ self loadItems:@"/Library/Desktop Pictures" withRepresentationType:kMMFlowViewURLRepresentationType ];
	// load all the movies
	NSArray * paths = NSSearchPathForDirectoriesInDomains( NSMoviesDirectory, NSUserDomainMask, YES);
	NSString *moviesPath = [paths objectAtIndex:0];
	[ self loadItems:moviesPath withRepresentationType:kMMFlowViewQTMoviePathRepresentationType ];
	// image loading via bindings
	self.flowView.imageTitleKeyPath = @"title";
	self.flowView.imageRepresentationKeyPath = @"image";
	self.flowView.imageRepresentationTypeKeyPath = @"type";
	self.flowView.imageUIDKeyPath = @"uid";
	[ self.flowView bind:NSContentArrayBinding
				toObject:self.itemArrayController
			 withKeyPath:@"arrangedObjects"
				 options:nil ];
	[ self.flowView bind:kMMFlowViewSelectedIndexKey
				toObject:self.itemArrayController
			 withKeyPath:@"selectionIndex"
				 options:nil ];
	// turn quicklook on
	[ self.flowView setCanControlQuickLookPanel:YES ];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

#pragma mark -
#pragma mark accesors

- (NSArray*)items
{
	return [ [ items retain ] autorelease ];
}

- (void)setItems:(NSArray *)someItems
{
	if ( items != someItems ) {
		[ items release ];
		items = [ someItems mutableCopy ];
	}
}

- (NSUInteger)countOfItems
{
	return [ items count ];
}

- (id)objectInItemsAtIndex:(NSUInteger)index
{
	return [ items objectAtIndex:index ];
}

- (NSArray*)itemsAtIndexes:(NSIndexSet *)indexes
{
	return [ items objectsAtIndexes:indexes ];
}

- (void)insertObject:(id)object inItemsAtIndex:(NSUInteger)index
{
	[ items insertObject:object atIndex:index ];
}

- (void)insertItems:(NSArray *)array atIndexes:(NSIndexSet*)indexes
{
	[ items insertObjects:array atIndexes:indexes ];
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)index
{
	[ items removeObjectAtIndex:index ];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
	[ items removeObjectsAtIndexes:indexes ];
}


#pragma mark -
#pragma mark private implementation

- (void)loadItems:(NSString*)aPath withRepresentationType:(NSString*)aRepresentationType
{
	//[ self removeItemsAtIndexes:[ NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [ self countOfItems ] ) ] ];
	NSFileManager *fileManager = [ NSFileManager defaultManager ];
	BOOL isDirectory = NO;
    BOOL exists = [ fileManager fileExistsAtPath:aPath isDirectory:&isDirectory ];
	
	if ( exists && isDirectory ) {
		NSDirectoryEnumerator *dirEnumerator = [ fileManager enumeratorAtURL:[ NSURL fileURLWithPath:aPath ]
												  includingPropertiesForKeys:[ NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil ]
																	 options:NSDirectoryEnumerationSkipsHiddenFiles
																errorHandler:nil ];
		for ( NSURL *url in dirEnumerator ) {
			NSNumber *isDirectory = NO;
			[ url getResourceValue:&isDirectory
							forKey:NSURLIsDirectoryKey
							 error:NULL ];
			if ( ![ isDirectory boolValue ] ) {
				[ self insertObject:[ Item itemWithURL:url representationType:aRepresentationType ]
					 inItemsAtIndex:[ self countOfItems ] ];
			}
		}
	}
}

- (void)loadPDFDocument:(NSURL*)anURL
{
	//[ self removeItemsAtIndexes:[ NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [ self countOfItems ] ) ] ];
	PDFDocument *document = [ [ [ PDFDocument alloc ] initWithURL:anURL ] autorelease ];
	
	for ( NSUInteger i = 0; i < document.pageCount; ++i ) {
		PDFPage *page = [ document pageAtIndex:i ];
		[ self insertObject:[ Item itemWithPDFPage:page ] inItemsAtIndex:[ self countOfItems ] ];
	}
}

#pragma mark -
#pragma mark MMFlowViewDataSource

- (NSUInteger)numberOfItemsInFlowView:(MMFlowView *)aFlowView
{
	return [ self countOfItems ];
}

- (id<MMFlowViewItem>)flowView:(MMFlowView *)aFlowView itemAtIndex:(NSUInteger)index
{
	return [ self objectInItemsAtIndex:index ];
}

- (void)flowViewSelectionDidChange:(MMFlowView *)aFlowView
{
	[ self.imageBrowserView setSelectionIndexes:[ NSIndexSet indexSetWithIndex:aFlowView.selectedIndex ]
						   byExtendingSelection:NO ];
	[ self.imageBrowserView scrollIndexToVisible:aFlowView.selectedIndex ];
}

- (NSDragOperation)flowView:(MMFlowView *)aFlowView validateDrop:(id<NSDraggingInfo>)info proposedIndex:(NSUInteger)anIndex
{
	return NSDragOperationCopy;
}

- (BOOL)flowView:(MMFlowView *)aFlowView acceptDrop:(id<NSDraggingInfo>)info atIndex:(NSUInteger)anIndex
{
	return YES;
}

#pragma mark -
#pragma mark IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [ self countOfItems ];
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
	return [ self objectInItemsAtIndex:index ];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)openDocument:(id)sender
{
	NSOpenPanel *panel = [ NSOpenPanel openPanel ];
	
	[ panel setAllowedFileTypes:[ NSArray arrayWithObject:@"com.adobe.pdf" ] ];
	[ panel beginWithCompletionHandler:^(NSInteger result) {
		if ( result == NSFileHandlingPanelOKButton ) {
			[ self loadPDFDocument:[ panel URL ] ];
			[ self.flowView reloadContent ];
		}
	} ];
}

- (IBAction)toggleReflection:(id)sender
{
	BOOL show = [ (NSButton*)sender state ] == NSOnState ? YES : NO;
	self.flowView.showsReflection = show;
	[ self.reflectionSlider setHidden:!show ];
}

- (IBAction)toggleAngle:(id)sender
{
	self.flowView.stackedAngle = [ sender selectedTag ];
}

- (IBAction)toggleSpacing:(id)sender
{
	self.flowView.spacing = [ sender selectedTag ];
}

- (IBAction)reflectionChanged:(NSSlider *)sender
{
	self.flowView.reflectionOffset = -[ sender floatValue ] / 100.0;
}

- (IBAction)previewScaleChanged:(NSSlider *)sender
{
	self.flowView.previewScale = [ sender floatValue ];
}

@end


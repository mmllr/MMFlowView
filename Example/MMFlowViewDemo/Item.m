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
//  Item.m
//  FlowView
//
//  Created by Markus Müller on 14.01.12.
//  Copyright (c) 2012 www.isnotnil.com. All rights reserved.
//

#import "Item.h"
#import <Quartz/Quartz.h>
#import "MMFlowView.h"

@implementation Item

+ (NSString*)mapRepresentationTypeFromFlowViewItemToImageBrowserItem:(NSString*)aFlowViewItemRepresentationType
{
	static NSDictionary *mappingDict = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mappingDict = @{kMMFlowViewURLRepresentationType: IKImageBrowserNSURLRepresentationType,
					   kMMFlowViewCGImageRepresentationType: IKImageBrowserCGImageRepresentationType,
					   kMMFlowViewPDFPageRepresentationType: IKImageBrowserPDFPageRepresentationType,
					   kMMFlowViewPathRepresentationType: IKImageBrowserPathRepresentationType,
					   kMMFlowViewNSImageRepresentationType: IKImageBrowserNSImageRepresentationType,
					   kMMFlowViewCGImageSourceRepresentationType: IKImageBrowserCGImageSourceRepresentationType,
					   kMMFlowViewNSDataRepresentationType: IKImageBrowserNSDataRepresentationType,
					   kMMFlowViewNSBitmapRepresentationType: IKImageBrowserNSBitmapImageRepresentationType,
					   kMMFlowViewQTMovieRepresentationType: IKImageBrowserQTMovieRepresentationType,
					   kMMFlowViewQTMoviePathRepresentationType: IKImageBrowserQTMoviePathRepresentationType,
					   kMMFlowViewQCCompositionRepresentationType: IKImageBrowserQCCompositionRepresentationType,
					   kMMFlowViewQCCompositionPathRepresentationType: IKImageBrowserQCCompositionPathRepresentationType,
						kMMFlowViewQuickLookPathRepresentationType: IKImageBrowserQuickLookPathRepresentationType };
	});
	return mappingDict[aFlowViewItemRepresentationType];
}

+ (id)itemWithURL:(NSURL*)anURL representationType:(NSString*)aRepresentationType
{
	return [ [ self  alloc ] initWithURL:anURL
						representationType:aRepresentationType ];
}

+ (id)itemWithPDFPage:(PDFPage*)aPDFPage
{
	return [ [ self  alloc ] initWithPDFPage:aPDFPage ];
}

- (id)initWithURL:(NSURL*)anURL representationType:(NSString*)aRepresentationType
{
    self = [super init];
    if (self) {
        self.image = anURL;
		self.type = aRepresentationType ? aRepresentationType : kMMFlowViewURLRepresentationType;
		self.title = [ [ anURL path ] lastPathComponent ];
		self.uid = [ anURL absoluteString ];
    }
    return self;
}

- (id)initWithPDFPage:(PDFPage*)aPDFPage {
    self = [super init];
    if (self) {
        self.image = aPDFPage;
		self.type = kMMFlowViewPDFPageRepresentationType;
		self.title = [ NSString stringWithFormat:@"Page %@", @([ [ aPDFPage document ] indexForPage:aPDFPage ] + 1 ) ];
		self.uid = self.imageItemTitle;
    }
    return self;
}

#pragma mark -
#pragma mark IKImageBrowserItem protocol

- (id)imageRepresentation
{
	return self.image;
}

- (NSString *)imageUID
{
	return self.uid;
}

- (NSString *)imageRepresentationType
{
	return [ [ self class ] mapRepresentationTypeFromFlowViewItemToImageBrowserItem:self.type ];
}

- (NSString *)imageTitle
{
	return self.title;
}

#pragma mark -
#pragma mark MMFlowViewItem protocol

- (id)imageItemRepresentation
{
	return self.image;
}

- (NSString*)imageItemUID
{
	return self.uid;
}

- (NSString*)imageItemRepresentationType
{
	return self.type;
}

- (NSString*)imageItemTitle
{
	return self.title;
}

@end

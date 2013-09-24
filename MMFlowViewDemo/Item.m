/*
 Copyright (c) 2012, Markus Müller, www.isnotnil.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

static const NSInteger kMaxPreviewSize = 400;

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
					   kMMFlowViewQuickLookPathRepresentationType: IKImageBrowserQuickLookPathRepresentationType,
					   kMMFlowViewIconRefPathRepresentationType: IKImageBrowserIconRefPathRepresentationType,
					   kMMFlowViewIconRefRepresentationType: IKImageBrowserIconRefRepresentationType};
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

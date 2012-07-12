/*
 Copyright (c) 2012, Markus Müller, www.isnotnil.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  Item.h
//  FlowView
//
//  Created by Markus Müller on 14.01.12.
//  Copyright (c) 2012 www.isnotnil.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMFlowView.h"

@class PDFPage;

@interface Item : NSObject<MMFlowViewItem>
{
	id image;
	NSString *type;
	NSString *title;
	NSString *uid;
}

@property (nonatomic,retain) id image;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *uid;

+ (id)itemWithURL:(NSURL*)anURL representationType:(NSString*)aRepresentationType;
+ (id)itemWithPDFPage:(PDFPage*)aPDFPage;

- (id)initWithURL:(NSURL*)anURL representationType:(NSString*)aRepresentationType;
- (id)initWithPDFPage:(PDFPage*)aPDFPage;

@end

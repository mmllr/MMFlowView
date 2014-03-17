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
#ifndef __MM_MACROS_H
#define __MM_MACROS_H

#import <Foundation/Foundation.h>

#ifndef SAFE_CGIMAGE_RELEASE
#define SAFE_CGIMAGE_RELEASE(image) if (image) { CGImageRelease(image); image = NULL; }
#endif // SAFE_CGIMAGE_RELEASE

#ifndef CLAMP
#define CLAMP(value, lowerBound, upperbound) MAX( lowerBound, MIN( upperbound, value ))
#endif

#ifndef CGAFFINE_TRANSFORM_TO_NSAFFINE_TRANSFORM_STRUCT
#define CGAFFINE_TRANSFORM_TO_NSAFFINE_TRANSFORM_STRUCT(cgt) { cgt.a, cgt.b, cgt.c, cgt.d, cgt.tx, cgt.ty };
#endif

inline NSAffineTransformStruct MakeNSAffineTransformFromCGAffineTransform(CGAffineTransform cgTransform) {
	NSAffineTransformStruct nsTransform = CGAFFINE_TRANSFORM_TO_NSAFFINE_TRANSFORM_STRUCT(cgTransform);
	return nsTransform;
}

#endif // __MM_MACROS_H
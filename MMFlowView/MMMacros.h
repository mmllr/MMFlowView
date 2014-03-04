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
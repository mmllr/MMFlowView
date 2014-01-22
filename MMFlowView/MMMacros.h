#ifndef __MM_MACROS_H
#define __MM_MACROS_H

#ifndef SAFE_CGIMAGE_RELEASE
#define SAFE_CGIMAGE_RELEASE(image) if (image) { CGImageRelease(image); image = NULL; }
#endif // SAFE_CGIMAGE_RELEASE

#endif // __MM_MACROS_H
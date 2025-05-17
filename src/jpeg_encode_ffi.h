#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

/* Public Domain, Simple, Minimalistic JPEG writer - http://jonolick.com
 *
 * Quick Notes:
 * 	Based on a javascript jpeg writer
 * 	JPEG baseline (no JPEG progressive)
 * 	Supports 1, 3 or 4 component input. (luminance, RGB or RGBX)
 *
 * Latest revisions:
 *  1.61 (2025-02-25) Minor changes: C compatibility. reduced number of lines of code.
 *  1.60 (2019-27-11) Added support for subsampling U,V so that it encodes smaller files. Enabled when quality <= 90.
 *	1.52 (2012-22-11) Added support for specifying Luminance, RGB, or RGBA via comp(onents) argument (1, 3 and 4 respectively).
 *	1.51 (2012-19-11) Fixed some warnings
 *	1.50 (2012-18-11) MT safe. Simplified. Optimized. Reduced memory requirements. Zero allocations. No namespace polution. Approx 340 lines code.
 *	1.10 (2012-16-11) compile fixes, added docs,
 *		changed from .h to .cpp (simpler to bootstrap), etc
 * 	1.00 (2012-02-02) initial release
 *
 * Basic usage:
 *	char *foo = new char[128*128*4]; // 4 component. RGBX format, where X is unused
 *	jo_write_jpg("foo.jpg", foo, 128, 128, 4, 90); // comp can be 1, 3, or 4. Lum, RGB, or RGBX respectively.
 *
 * */

#ifndef JO_INCLUDE_JPEG_H
#define JO_INCLUDE_JPEG_H

// To get a header file for this, either cut and paste the header,
// or create jo_jpeg.h, #define JO_JPEG_HEADER_FILE_ONLY, and
// then include jo_jpeg.c from it.

// Returns false on failure
FFI_PLUGIN_EXPORT int jo_write_jpg(const char *filename, const char *data, int width, int height, int comp, int quality);

#endif // JO_INCLUDE_JPEG_H

#ifndef JO_JPEG_HEADER_FILE_ONLY

#if defined(_MSC_VER) && _MSC_VER >= 0x1400
#define _CRT_SECURE_NO_WARNINGS // suppress warnings about fopen()
#endif

#endif // JO_JPEG_HEADER_FILE_ONLY
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <QuartzCore/QuartzCore.h>
#endif

typedef struct SVGCurve
{
    CGPoint c1;
    CGPoint c2;
    CGPoint p;
} SVGCurve;

SVGCurve SVGCurveMake(CGFloat cx1, CGFloat cy1, CGFloat cx2, CGFloat cy2, CGFloat px, CGFloat py);
BOOL SVGCurveEqualToCurve(SVGCurve curve1, SVGCurve curve2);

#define SVGCurveZero SVGCurveMake(0.,0.,0.,0.,0.,0.)

@interface JMapKPointsAndPathsParser : NSObject

//@property (nonatomic, unsafe_unretained) CGContextRef context;

- (void) readWhitespace:(NSScanner*)scanner;
- (void) readCommaAndWhitespace:(NSScanner*)scanner;

- (void) readCoordinate:(NSScanner*)scanner intoFloat:(CGFloat*) floatPointer;
- (CGPoint) readCoordinatePair:(NSScanner*)scanner;

- (CGPoint) readMovetoDrawtoCommandGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (CGPoint) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (CGPoint) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (CGPoint) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;

- (CGPoint) readLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (CGPoint) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (CGPoint) readVerticalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readVerticalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readHorizontalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readHorizontalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

- (SVGCurve) readQuadraticCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (SVGCurve) readQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (SVGCurve) readQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (SVGCurve) readSmoothQuadraticCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;
- (SVGCurve) readSmoothQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;
- (SVGCurve) readSmoothQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;

- (SVGCurve) readCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (SVGCurve) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
- (SVGCurve) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (SVGCurve) readSmoothCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;
- (SVGCurve) readSmoothCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;
- (SVGCurve) readSmoothCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;

- (SVGCurve)  readEllipticalArcArguments:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

- (CGPoint) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

@end

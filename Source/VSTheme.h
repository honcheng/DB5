//
//  VSTheme.h
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VSTextCaseTransform) {
    VSTextCaseTransformNone,
    VSTextCaseTransformUpper,
    VSTextCaseTransformLower
};


@class VSAnimationSpecifier;

@interface VSTheme : NSObject

- (id)initWithDictionary:(NSDictionary *)themeDictionary;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) VSTheme *parentTheme; /*can inherit*/

- (BOOL)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (NSTimeInterval)timeIntervalForKey:(NSString *)key;

/** Via \c +UIImage imageNamed: */
- (UIImage *)imageForKey:(NSString *)key;

/** Dictionary with hex key containing 123ABC or #123ABC: 6 digits, leading # allowed but not required, and optional alpha key containing number 0-1 */
- (UIColor *)colorForKey:(NSString *)key;

/** Dictionary with top, left, right, bottoms keys */
- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key;

/** Dictionary with name key containing the fully specified name fo the font, and size key containing size of the font in points */
- (UIFont *)fontForKey:(NSString *)key;

/** Dictionary with name key containing the fully specified name fo the font, and size key containing size of the font in points. Optionally make adjustment to the size of the font by providing a positive or negative value in sizeAdjustment */
- (UIFont *)fontForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment;

/** Dictionary with x and y keys */
- (CGPoint)pointForKey:(NSString *)key;

/** Dictionary with width and height keys */
- (CGSize)sizeForKey:(NSString *)key;

/** Dictionary containing the keys duration, delay and curve, where the possible values for curve are easeinout, easeout, easein, linear */
- (VSAnimationSpecifier *)animationSpecifierForKey:(NSString *)key;

/** lowercase or uppercase -- returns VSTextCaseTransformNone */
- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key;

/** Returns YES only if the theme explicitly provides the key */
- (BOOL)containsKey:(NSString *)key;

/** Returns YES if either the theme or the parent provides the key */
- (BOOL)containsOrInheritsKey:(NSString *)key;

- (void)clearFontCache;
- (void)clearColorCache;

@end


@interface VSTheme (Animations)

- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end


@interface VSAnimationSpecifier : NSObject

@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIViewAnimationOptions curve;

@end


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


@class VSAnimationSpecifier, VSViewSpecifier, VSTextLabelSpecifier;

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

- (VSViewSpecifier *)viewSpecifierForKey:(NSString *)key;

- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key;

/** Optionally make adjustment to the size of the font by providing a positive or negative value in sizeAdjustment */
- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment;

/** Where the possible values for curve are left, center, right, justified, natural */
- (NSTextAlignment)textAlignmentForKey:(NSString *)key;

/** Returns YES only if the theme explicitly provides the key */
- (BOOL)containsKey:(NSString *)key;

/** Returns YES if either the theme or the parent provides the key */
- (BOOL)containsOrInheritsKey:(NSString *)key;

- (void)clearFontCache;
- (void)clearColorCache;
- (void)clearViewSpecifierCache;
- (void)clearTextLabelSpecifierCache;

@end


@interface VSTheme (Animations)

- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end


@interface VSTheme (Labels)

- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)animationSpecifierKey;

- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)animationSpecifierKey sizeAdjustment:(CGFloat)sizeAdjustment;

@end


@interface VSTheme (View)

- (UIView *)viewWithViewSpecifierKey:(NSString *)viewSpecifierKey;

@end


@interface VSAnimationSpecifier : NSObject

@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIViewAnimationOptions curve;

@end

@interface VSViewSpecifier : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, copy) UIColor *backgroundColor;

@end

@interface VSTextLabelSpecifier : NSObject

@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) CGSize size;
/** If YES, \c size should be ignored when creating a text label from it */
@property (nonatomic, assign) BOOL sizeToFit;
@property (nonatomic, assign) CGPoint position;
/** Not used when creating a view \c -viewWithViewSpecifierKey: */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) NSTextAlignment alignment;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, copy) UIColor *backgroundColor;

@end

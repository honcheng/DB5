//
//  VSTheme.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSTheme.h"


static BOOL stringIsEmpty(NSString *s);
static UIColor *colorWithHexString(NSString *hexString);


@interface VSTheme ()

@property (nonatomic, strong) NSDictionary *themeDictionary;
@property (nonatomic, strong) NSCache *colorCache;
@property (nonatomic, strong) NSCache *fontCache;
@property (nonatomic, strong) NSCache *viewSpecifierCache;
@property (nonatomic, strong) NSCache *textLabelSpecifierCache;
@end


@implementation VSTheme


#pragma mark Init

- (id)initWithDictionary:(NSDictionary *)themeDictionary {
	
	self = [super init];
	if (self == nil)
		return nil;
	
	_themeDictionary = themeDictionary;

	return self;
}

/**
 
 Lazy accessors for Cache
 
 */

#pragma mark - Lazy Accessors for Cache


- (NSCache *)colorCache {
	
	if (!_colorCache)
		_colorCache = [NSCache new];
	
	return _colorCache;
}


- (NSCache *)fontCache {
	
	if (!_fontCache)
		_fontCache = [NSCache new];
	
	return _fontCache;
}


- (NSCache *)viewSpecifierCache {
	
	if (!_viewSpecifierCache)
		_viewSpecifierCache = [NSCache new];
	
	return _viewSpecifierCache;
}


- (NSCache *)textLabelSpecifierCache {
	
	if (!_textLabelSpecifierCache)
		_textLabelSpecifierCache = [NSCache new];
	
	return _textLabelSpecifierCache;
}


/**
 
 Basic Methods To Obtain Data From Plist
 
 */

#pragma mark - Basic Methods To Obtain Data From Plist


- (id)objectForKey:(NSString *)key {

	id obj = [self.themeDictionary valueForKeyPath:key];
	if (obj == nil && self.parentTheme != nil)
		obj = [self.parentTheme objectForKey:key];
	return obj;
}


- (NSDictionary *)dictionaryForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self dictionaryFromObject:obj];
}


- (NSDictionary *)dictionaryFromObject:(id)obj {
	
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSDictionary class]])
		return obj;
	return nil;
}


/**
 
 Basic Data Types
 
 */

#pragma mark - Basic Data Types


- (BOOL)boolForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self vs_boolForObject:obj];
}


- (BOOL)vs_boolForObject:(id)obj {
	
	if (obj == nil)
		return NO;
	return [obj boolValue];
}


- (NSString *)stringForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_stringFromObject:obj];
}


- (NSString *)vs_stringFromObject:(id)obj {
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSString class]])
		return obj;
	if ([obj isKindOfClass:[NSNumber class]])
		return [obj stringValue];
	return nil;
}


- (NSInteger)integerForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self vs_integerFromObject:obj];
}


- (NSInteger)vs_integerFromObject:(id)obj {
	
	if (obj == nil)
		return 0;
	return [obj integerValue];
}


- (CGFloat)floatForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_floatFromObject:obj];
}


- (CGFloat)vs_floatFromObject:(id)obj {
	
	if (obj == nil)
		return  0.0f;
	return [obj floatValue];
}


- (NSTimeInterval)timeIntervalForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self vs_timeIntervalFromObject:obj];
}


- (NSTimeInterval)vs_timeIntervalFromObject:(id)obj {
	
	if (obj == nil)
		return 0.0;
	return [obj doubleValue];
}


/**
 
 Advanced Data Types
 
 */

#pragma mark - Advanced Data Types


- (UIImage *)imageForKey:(NSString *)key {
	
	NSString *imageName = [self stringForKey:key];
	if (stringIsEmpty(imageName))
		return nil;
	
	return [UIImage imageNamed:imageName];
}


- (UIColor *)colorForKey:(NSString *)key {

	UIColor *cachedColor = [self.colorCache objectForKey:key];
	if (cachedColor != nil)
		return cachedColor;
    
	NSDictionary *colorDictionary = [self dictionaryForKey:key];
	UIColor *color = [self vs_colorFromDictionary:colorDictionary];
	
	[self.colorCache setObject:color forKey:key];

	return color;
}


- (UIColor *)vs_colorFromDictionary:(NSDictionary *)colorDictionary {
	
	UIColor *color = nil;
	
	if (colorDictionary) {
		NSString *hexString = [self vs_stringFromObject:colorDictionary[@"hex"]];
		
		if (hexString) {
			color = colorWithHexString(hexString);
			
			if (colorDictionary[@"alpha"] != nil) {
				CGFloat alpha = [self vs_floatFromObject:colorDictionary[@"alpha"]];
				color = [color colorWithAlphaComponent:alpha];
			}
		}
	}
	
	if (color == nil)
		color = [UIColor blackColor];
	
	return color;
}


- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key {

	NSDictionary *insetsDictionary = [self dictionaryForKey:key];
	UIEdgeInsets edgeInsets = [self vs_edgeInsetsFromDictionary:insetsDictionary];
	return edgeInsets;
}


- (UIEdgeInsets)vs_edgeInsetsFromDictionary:(NSDictionary *)insetsDictionary {
	
	CGFloat left = [self vs_floatFromObject:insetsDictionary[@"left"]];
	CGFloat top = [self vs_floatFromObject:insetsDictionary[@"top"]];
	CGFloat right = [self vs_floatFromObject:insetsDictionary[@"right"]];
	CGFloat bottom = [self vs_floatFromObject:insetsDictionary[@"bottom"]];
	
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
	return edgeInsets;
}


- (UIFont *)fontForKey:(NSString *)key {
	
	return [self fontForKey:key sizeAdjustment:0];
}


- (UIFont *)fontForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment {
	
	NSString *cacheKey = [key stringByAppendingFormat:@"_%.2f", sizeAdjustment];
	UIFont *cachedFont = [self.fontCache objectForKey:cacheKey];
	if (cachedFont != nil)
		return cachedFont;
    
	NSDictionary *fontDictionary = [self dictionaryForKey:key];
	UIFont *font = [self vs_fontFromDictionary:fontDictionary sizeAdjustment:sizeAdjustment];
    
	[self.fontCache setObject:font forKey:cacheKey];
	
	return font;
}


- (UIFont *)vs_fontFromDictionary:(NSDictionary *)fontDictionary sizeAdjustment:(CGFloat)sizeAdjustment {
	
	NSString *fontName = [self vs_stringFromObject:fontDictionary[@"name"]];
	CGFloat fontSize = [self vs_floatFromObject:fontDictionary[@"size"]];
	
	fontSize += sizeAdjustment;
	
	if (fontSize < 1.0f)
		fontSize = 15.0f;
	
	UIFont *font = nil;
    
	if (stringIsEmpty(fontName))
		font = [UIFont systemFontOfSize:fontSize];
	else
		font = [UIFont fontWithName:fontName size:fontSize];
	
	if (font == nil)
		font = [UIFont systemFontOfSize:fontSize];
    
	return font;
}


- (CGPoint)pointForKey:(NSString *)key {

	NSDictionary *pointDictionary = [self dictionaryForKey:key];
	return [self vs_pointFromDictionary:pointDictionary];
}


- (CGPoint)vs_pointFromDictionary:(NSDictionary *)pointDictionary {
	
	CGFloat pointX = [self vs_floatFromObject:pointDictionary[@"x"]];
	CGFloat pointY = [self vs_floatFromObject:pointDictionary[@"y"]];
	
	CGPoint point = CGPointMake(pointX, pointY);
	return point;
}


- (CGSize)sizeForKey:(NSString *)key {

	NSDictionary *sizeDictionary = [self dictionaryForKey:key];
	return [self vs_sizeFromDictionary:sizeDictionary];
}


- (CGSize)vs_sizeFromDictionary:(NSDictionary *)sizeDictionary {
	
	CGFloat width = [self vs_floatFromObject:sizeDictionary[@"width"]];
	CGFloat height = [self vs_floatFromObject:sizeDictionary[@"height"]];
	
	CGSize size = CGSizeMake(width, height);
	return size;
}


- (UIViewAnimationOptions)vs_curveFromObject:(id)obj {
    
	NSString *curveString = [self vs_stringFromObject:obj];
	if (stringIsEmpty(curveString))
		return UIViewAnimationOptionCurveEaseInOut;

	curveString = [curveString lowercaseString];
	if ([curveString isEqualToString:@"easeinout"])
		return UIViewAnimationOptionCurveEaseInOut;
	else if ([curveString isEqualToString:@"easeout"])
		return UIViewAnimationOptionCurveEaseOut;
	else if ([curveString isEqualToString:@"easein"])
		return UIViewAnimationOptionCurveEaseIn;
	else if ([curveString isEqualToString:@"linear"])
		return UIViewAnimationOptionCurveLinear;
    
	return UIViewAnimationOptionCurveEaseInOut;
}


- (VSAnimationSpecifier *)animationSpecifierForKey:(NSString *)key {

	VSAnimationSpecifier *animationSpecifier = [VSAnimationSpecifier new];

	NSDictionary *animationDictionary = [self dictionaryForKey:key];
	
	animationSpecifier.duration = [self vs_timeIntervalFromObject:animationDictionary[@"duration"]];
	animationSpecifier.delay = [self vs_timeIntervalFromObject:animationDictionary[@"delay"]];
	animationSpecifier.curve = [self vs_curveFromObject:animationDictionary[@"delay"]];

	return animationSpecifier;
}


- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key {

	NSString *s = [self stringForKey:key];
	if (s == nil)
		return VSTextCaseTransformNone;

	if ([s caseInsensitiveCompare:@"lowercase"] == NSOrderedSame)
		return VSTextCaseTransformLower;
	else if ([s caseInsensitiveCompare:@"uppercase"] == NSOrderedSame)
		return VSTextCaseTransformUpper;

	return VSTextCaseTransformNone;
}


- (VSViewSpecifier *)viewSpecifierForKey:(NSString *)key {
	
	VSViewSpecifier *cachedSpecifier = [self.viewSpecifierCache objectForKey:key];
	if (cachedSpecifier != nil)
		return cachedSpecifier;
	
	VSViewSpecifier *viewSpecifier = [VSViewSpecifier new];
	NSDictionary *dictionary = [self dictionaryForKey:key];

	NSDictionary *sizeDictionary = [self dictionaryFromObject:dictionary[@"size"]];
	viewSpecifier.size = [self vs_sizeFromDictionary:sizeDictionary];

	NSDictionary *positionDictionary = [self dictionaryFromObject:dictionary[@"position"]];
	viewSpecifier.position = [self vs_pointFromDictionary:positionDictionary];

	NSDictionary *backgroundColorDictionary = [self dictionaryFromObject:dictionary[@"backgroundColor"]];
	if (backgroundColorDictionary)
		viewSpecifier.backgroundColor = [self vs_colorFromDictionary:backgroundColorDictionary];
	
	NSDictionary *edgeInsetsDictionary = [self dictionaryFromObject:dictionary[@"padding"]];
	viewSpecifier.padding = [self vs_edgeInsetsFromDictionary:edgeInsetsDictionary];
	
	[self.viewSpecifierCache setObject:viewSpecifier forKey:key];
	
	return viewSpecifier;
}


- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key {
	
	return [self textLabelSpecifierForKey:key sizeAdjustment:0];
}


- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment {
	
	NSString *cacheKey = [key stringByAppendingFormat:@"_%.2f", sizeAdjustment];
	VSTextLabelSpecifier *cachedSpecifier = [self.textLabelSpecifierCache objectForKey:cacheKey];
	if (cachedSpecifier != nil)
		return cachedSpecifier;
	
	VSTextLabelSpecifier *labelSpecifier = [VSTextLabelSpecifier new];
	NSDictionary *dictionary = [self dictionaryForKey:key];
	
	NSDictionary *fontDictionary = [self dictionaryFromObject:dictionary[@"font"]];
	labelSpecifier.font = [self vs_fontFromDictionary:fontDictionary sizeAdjustment:sizeAdjustment];
	
	NSDictionary *sizeDictionary = [self dictionaryFromObject:dictionary[@"size"]];
	labelSpecifier.size = [self vs_sizeFromDictionary:sizeDictionary];
	
	labelSpecifier.sizeToFit = [self vs_boolForObject:dictionary[@"sizeToFit"]];

	NSDictionary *positionDictionary = [self dictionaryFromObject:dictionary[@"position"]];
	labelSpecifier.position = [self vs_pointFromDictionary:positionDictionary];

	NSDictionary *alignmentDictionary = [self dictionaryFromObject:dictionary[@"alignment"]];
	labelSpecifier.alignment = [self vs_textAlignmentFromObject:alignmentDictionary];

	NSDictionary *colorDictionary = [self dictionaryFromObject:dictionary[@"color"]];
	if (colorDictionary)
		labelSpecifier.color = [self vs_colorFromDictionary:colorDictionary];

	NSDictionary *backgroundColorDictionary = [self dictionaryFromObject:dictionary[@"backgroundColor"]];
	if (backgroundColorDictionary)
		labelSpecifier.backgroundColor = [self vs_colorFromDictionary:backgroundColorDictionary];
	
	NSDictionary *edgeInsetsDictionary = [self dictionaryFromObject:dictionary[@"padding"]];
	labelSpecifier.padding = [self vs_edgeInsetsFromDictionary:edgeInsetsDictionary];
	
	[self.textLabelSpecifierCache setObject:labelSpecifier forKey:cacheKey];
	
	return labelSpecifier;
}


- (NSTextAlignment)textAlignmentForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_textAlignmentFromObject:obj];
}


- (NSTextAlignment)vs_textAlignmentFromObject:(id)obj {
    
	NSString *alignmentString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(alignmentString)) {
		alignmentString = [alignmentString lowercaseString];
		if ([alignmentString isEqualToString:@"left"])
			return NSTextAlignmentLeft;
		else if ([alignmentString isEqualToString:@"center"])
			return NSTextAlignmentCenter;
		else if ([alignmentString isEqualToString:@"right"])
			return NSTextAlignmentRight;
		else if ([alignmentString isEqualToString:@"justified"])
			return NSTextAlignmentJustified;
		else if ([alignmentString isEqualToString:@"natural"])
			return NSTextAlignmentNatural;
	}
    
	return NSTextAlignmentLeft;
}


/**
 
 Other Public Helper Methods
 
 */

#pragma mark - Other Public Helper Methods


- (BOOL)containsKey:(NSString *)key {
	
	id obj = [self.themeDictionary valueForKeyPath:key];

	if (obj == nil)
		return NO;
	
	return YES;
}


- (BOOL)containsOrInheritsKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	
	if (obj == nil)
		return NO;
	
	return YES;
}


- (void)clearFontCache
{
	[self.fontCache removeAllObjects];
}


- (void)clearColorCache
{
	[self.colorCache removeAllObjects];
}


- (void)clearViewSpecifierCache
{
	[self.viewSpecifierCache removeAllObjects];
}


- (void)clearTextLabelSpecifierCache
{
	[self.textLabelSpecifierCache removeAllObjects];
}

@end


@implementation VSTheme (Animations)


- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {

    VSAnimationSpecifier *animationSpecifier = [self animationSpecifierForKey:animationSpecifierKey];

    [UIView animateWithDuration:animationSpecifier.duration delay:animationSpecifier.delay options:animationSpecifier.curve animations:animations completion:completion];
}


@end


@implementation VSTheme (Labels)


- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)labelSpecifierKey {
	
	return [self labelWithText:text specifierKey:labelSpecifierKey sizeAdjustment:0];
}

- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)labelSpecifierKey sizeAdjustment:(CGFloat)sizeAdjustment {
	
	VSTextLabelSpecifier *textLabelSpecifier = [self textLabelSpecifierForKey:labelSpecifierKey sizeAdjustment:sizeAdjustment];
	
	CGRect frame;
	frame.size = textLabelSpecifier.size;
	frame.origin = textLabelSpecifier.position;
	
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.text = text;

	label.font = textLabelSpecifier.font;
	label.textAlignment = textLabelSpecifier.alignment;
	
	if (textLabelSpecifier.color)
		label.textColor = textLabelSpecifier.color;
	
	if (textLabelSpecifier.backgroundColor)
		label.backgroundColor = textLabelSpecifier.backgroundColor;

	if (textLabelSpecifier.sizeToFit)
		[label sizeToFit];
	
	return label;
}

@end


@implementation VSTheme (View)

- (UIView *)viewWithViewSpecifierKey:(NSString *)viewSpecifierKey {
	
	VSViewSpecifier *viewSpecifier = [self viewSpecifierForKey:viewSpecifierKey];
	
	CGRect frame;
	frame.size = viewSpecifier.size;
	frame.origin = viewSpecifier.position;
	
	UIView *view = [[UIView alloc] initWithFrame:frame];
	
	view.backgroundColor = viewSpecifier.backgroundColor;
	
	return view;
}

@end


#pragma mark -

@implementation VSAnimationSpecifier

@end

@implementation VSViewSpecifier

@end

@implementation VSTextLabelSpecifier

@end


static BOOL stringIsEmpty(NSString *s) {
	return s == nil || [s length] == 0;
}


static UIColor *colorWithHexString(NSString *hexString) {

	/*Picky. Crashes by design.*/
	
	if (stringIsEmpty(hexString))
		return [UIColor blackColor];

	NSMutableString *s = [hexString mutableCopy];
	[s replaceOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)s);

	NSString *redString = [s substringToIndex:2];
	NSString *greenString = [s substringWithRange:NSMakeRange(2, 2)];
	NSString *blueString = [s substringWithRange:NSMakeRange(4, 2)];

	unsigned int red = 0, green = 0, blue = 0;
	[[NSScanner scannerWithString:redString] scanHexInt:&red];
	[[NSScanner scannerWithString:greenString] scanHexInt:&green];
	[[NSScanner scannerWithString:blueString] scanHexInt:&blue];

	return [UIColor colorWithRed:(CGFloat)red/255.0f green:(CGFloat)green/255.0f blue:(CGFloat)blue/255.0f alpha:1.0f];
}

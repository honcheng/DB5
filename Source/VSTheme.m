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

@end


@implementation VSTheme


#pragma mark Init

- (id)initWithDictionary:(NSDictionary *)themeDictionary {
	
	self = [super init];
	if (self == nil)
		return nil;
	
	_themeDictionary = themeDictionary;

	_colorCache = [NSCache new];
	_fontCache = [NSCache new];

	return self;
}


- (id)objectForKey:(NSString *)key {

	id obj = [self.themeDictionary valueForKeyPath:key];
	if (obj == nil && self.parentTheme != nil)
		obj = [self.parentTheme objectForKey:key];
	return obj;
}


- (NSDictionary *)dictionaryForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSDictionary class]])
		return obj;
	return nil;
}


/**
 
 Basic Data Types
 
 */


- (BOOL)boolForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self boolForObject:obj];
}


- (BOOL)boolForObject:(id)obj {
	
	if (obj == nil)
		return NO;
	return [obj boolValue];
}


- (NSString *)stringForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self stringFromObject:obj];
}


- (NSString *)stringFromObject:(id)obj {
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
	return [self integerFromObject:obj];
}


- (NSInteger)integerFromObject:(id)obj {
	
	if (obj == nil)
		return 0;
	return [obj integerValue];
}


- (CGFloat)floatForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self floatFromObject:obj];
}


- (CGFloat)floatFromObject:(id)obj {
	
	if (obj == nil)
		return  0.0f;
	return [obj floatValue];
}


- (NSTimeInterval)timeIntervalForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self timeIntervalFromObject:obj];
}


- (NSTimeInterval)timeIntervalFromObject:(id)obj {
	
	if (obj == nil)
		return 0.0;
	return [obj doubleValue];
}


/**
 
 Advanced Data Types
 
 */


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
	UIColor *color = nil;
	
	if (colorDictionary) {
		NSString *hexString = [self stringFromObject:colorDictionary[@"hex"]];
		
		if (hexString) {
			color = colorWithHexString(hexString);
			
			if (colorDictionary[@"alpha"] != nil) {
				CGFloat alpha = [self floatFromObject:colorDictionary[@"alpha"]];
				color = [color colorWithAlphaComponent:alpha];
			}
		}
	}
	
	if (color == nil)
		color = [UIColor blackColor];

	[self.colorCache setObject:color forKey:key];

	return color;
}


- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key {

	NSDictionary *insetsDictionary = [self dictionaryForKey:key];
	CGFloat left = [self floatFromObject:insetsDictionary[@"left"]];
	CGFloat top = [self floatFromObject:insetsDictionary[@"top"]];
	CGFloat right = [self floatFromObject:insetsDictionary[@"right"]];
	CGFloat bottom = [self floatFromObject:insetsDictionary[@"bottom"]];

	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
	return edgeInsets;
}


- (UIFont *)fontForKey:(NSString *)key {
	
	return [self fontForKey:key sizeAdjustment:0];
}


- (UIFont *)fontForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment {
	
	UIFont *cachedFont = [self.fontCache objectForKey:key];
	if (cachedFont != nil)
		return cachedFont;
    
	NSDictionary *fontDictionary = [self dictionaryForKey:key];
	NSString *fontName = [self stringFromObject:fontDictionary[@"name"]];
	CGFloat fontSize = [self floatFromObject:fontDictionary[@"size"]];
	
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
    
	[self.fontCache setObject:font forKey:key];
	
	return font;
	
}


- (CGPoint)pointForKey:(NSString *)key {

	NSDictionary *pointDictionary = [self dictionaryForKey:key];
	CGFloat pointX = [self floatFromObject:pointDictionary[@"x"]];
	CGFloat pointY = [self floatFromObject:pointDictionary[@"y"]];

	CGPoint point = CGPointMake(pointX, pointY);
	return point;
}


- (CGSize)sizeForKey:(NSString *)key {

	NSDictionary *sizeDictionary = [self dictionaryForKey:key];
	CGFloat width = [self floatFromObject:sizeDictionary[@"width"]];
	CGFloat height = [self floatFromObject:sizeDictionary[@"height"]];
	
	CGSize size = CGSizeMake(width, height);
	return size;
}


- (UIViewAnimationOptions)curveFromObject:(id)obj {
    
	NSString *curveString = [self stringFromObject:obj];
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
	
	animationSpecifier.duration = [self timeIntervalFromObject:animationDictionary[@"duration"]];
	animationSpecifier.delay = [self timeIntervalFromObject:animationDictionary[@"delay"]];
	animationSpecifier.curve = [self curveFromObject:animationDictionary[@"delay"]];

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

@end


@implementation VSTheme (Animations)


- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {

    VSAnimationSpecifier *animationSpecifier = [self animationSpecifierForKey:animationSpecifierKey];

    [UIView animateWithDuration:animationSpecifier.duration delay:animationSpecifier.delay options:animationSpecifier.curve animations:animations completion:completion];
}

@end


#pragma mark -

@implementation VSAnimationSpecifier

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

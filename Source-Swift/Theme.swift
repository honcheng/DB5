//
//  Theme.swift
//  DB5Demo-Swift
//
//  Created by Hon Cheng Muh on 12/1/17.
//  Copyright © 2017 Clean Shaven Apps Pte. Ltd. All rights reserved.
//

import UIKit

enum TextCaseTransform {
    case none
    case upper
    case lower
}

func stringIsEmpty(s: String?) -> Bool {
    guard let s = s else {
        return true
    }
    return s.characters.count == 0
}

// Picky. Crashes by design.
func colorWithHexString(hexString: String?) -> UIColor {
    
    guard let hexString = hexString else {
        return UIColor.black
    }
    if stringIsEmpty(s: hexString) {
        return UIColor.black
    }

    let s: NSMutableString = NSMutableString(string: hexString)
    s.replaceOccurrences(of: "#", with: "", options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(0, hexString.characters.count))
    CFStringTrimWhitespace(s)
    let redString = s.substring(to: 2)
    let greenString = s.substring(with: NSMakeRange(2, 2))
    let blueString = s.substring(with: NSMakeRange(4, 2))
    
    var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
    Scanner(string: redString).scanHexInt32(&r)
    Scanner(string: greenString).scanHexInt32(&g)
    Scanner(string: blueString).scanHexInt32(&b)
    
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
}

public class Theme: Equatable {
    
    public var name: String
    public var parentTheme: Theme?
    
    private var themeDictionary: [String: Any]
    
    public init?(name: String, themeDictionary: [String: Any]) {
        self.name = name
        self.themeDictionary = themeDictionary
    }
    
    public static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.name == rhs.name
    }
    
    // MARK: Lazy Accessors for Cache
    
    private lazy var colorCache: NSCache<NSString, UIColor> = {
        return NSCache()
    }()
    
    private lazy var fontCache: NSCache<NSString, UIFont> = {
        return NSCache()
    }()
    
    private lazy var viewSpecifierCache: NSCache<NSString, ViewSpecifier> = {
        return NSCache()
    }()
    
    private lazy var navigationBarSpecifierCache: NSCache<NSString, NavigationBarSpecifier> = {
        return NSCache()
    }()
    
    private lazy var textLabelSpecifierCache: NSCache<NSString, TextLabelSpecifier> = {
        return NSCache()
    }()
    
    // MARK: Basic Methods to Obtain Data from PLIST
    
    public func object(forKey key:String) -> Any? {
        
        let themeDictionary = self.themeDictionary as NSDictionary
        var obj = themeDictionary.value(forKeyPath: key)
        if obj == nil, let parentTheme = self.parentTheme {
            obj = parentTheme.object(forKey: key)
        }
        return obj
    }
    
    public func dictionary(forKey key: String) -> [String: Any]? {
        let obj = self.object(forKey: key) as? [String: Any]
        return obj
    }
    
    public func dictionary(fromObject object:Any?) -> [String: Any]? {
        return object as? [String: Any]
    }
    
    // MARK: Basic Data Types
    
    public func bool(forKey key: String) -> Bool {
        let obj = self.object(forKey: key)
        return self.bool(forObject: obj)
    }
    
    public func bool(forObject object: Any?) -> Bool {
        guard let object = object as? NSNumber else {
            return false
        }
        return object.boolValue
    }
    
    public func string(forKey key: String) -> String? {
        let obj = self.object(forKey: key)
        return self.string(fromObject: obj)
    }
    
    private func string(fromObject object: Any?) -> String? {
        guard let object = object else {
            return nil
        }
        if let object = object as? String {
            return object
        }
        else if let object = object as? NSNumber {
            return object.stringValue
        }
        return nil
    }
    
    public func integer(forKey key:String) -> Int {
        let obj = self.object(forKey: key)
        return self.integer(fromObject: obj)
    }
    
    public func integer(fromObject object:Any?) -> Int {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.intValue
    }
    
    public func float(forKey key:String) -> Float {
        let obj = self.object(forKey: key)
        return self.float(fromObject: obj)
    }
    
    private func float(fromObject object: Any?) -> Float {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.floatValue
    }
    
    public func timeInterval(forKey key:String) -> TimeInterval {
        let obj = self.object(forKey: key)
        return self.timeInterval(fromObject: obj)
    }
    
    public func timeInterval(fromObject object: Any?) -> TimeInterval {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.doubleValue
    }
    
    // MARK: Advanced Data Types
    
    public func image(forKey key:String) -> UIImage? {
        guard let imageName = self.string(forKey: key) else {
            return nil
        }
        if stringIsEmpty(s: imageName) {
            return nil
        }
        return UIImage(named: imageName)
    }
    
    public func color(forKey key: String) -> UIColor {
        guard let cachedColor = self.colorCache.object(forKey: key as NSString) else {
            let colorDictionary = self.dictionary(forKey: key)
            let color = self.color(fromDictionary: colorDictionary)
            self.colorCache.setObject(color, forKey: key as NSString)
            return color
        }
        return cachedColor
    }
    
    private func color(fromDictionary dictionary: [String: Any]?) -> UIColor {

        guard let dictionary = dictionary else {
            return UIColor.black
        }
        
        var color: UIColor?
        let alphaObject = dictionary["alpha"]
        if let hexString = dictionary["hex"] as? String {
            color = colorWithHexString(hexString: hexString)
            if let alphaObject = alphaObject {
                let alpha = self.float(fromObject: alphaObject)
                color = color?.withAlphaComponent(CGFloat(alpha))
            }
        }
        else if let alphaObject = alphaObject {
            let alpha = self.float(fromObject: alphaObject)
            if alpha == 0 {
                color = UIColor.clear
            }
        }
        
        if color == nil {
            color = UIColor.black
        }
        
        return color!
    }
    
    public func edgeInsets(forKey key: String) -> UIEdgeInsets {
        let insetsDictionary = self.dictionary(forKey: key)
        let edgeInsets = self.edgeInsets(fromDictionary: insetsDictionary)
        return edgeInsets
    }
    
    private func edgeInsets(fromDictionary dictionary: [String: Any]?) -> UIEdgeInsets {
        let left = CGFloat(self.float(fromObject: dictionary?["left"]))
        let top = CGFloat(self.float(fromObject: dictionary?["top"]))
        let right = CGFloat(self.float(fromObject: dictionary?["right"]))
        let bottom = CGFloat(self.float(fromObject: dictionary?["bottom"]))
        
        let edgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return edgeInsets
    }
    
//    func font(forKey key: String) -> UIFont? {
//    }

    
    public func font(forKey key:String, sizeAdjustment: Float) -> UIFont {
        let cacheKey = key.appendingFormat("_%.2f", sizeAdjustment)
        guard let cachedFont = self.fontCache.object(forKey: cacheKey as NSString) else {
            let fontDictionary = self.dictionary(forKey: key)
            let font = self.font(fromDictionary: fontDictionary, sizeAdjustment: sizeAdjustment)
            self.fontCache.setObject(font, forKey: cacheKey as NSString)
            return font
        }
        return cachedFont
        
        
    }
    
    private func font(fromDictionary dictionary: [String: Any]?, sizeAdjustment: Float) -> UIFont {
        let fontName = self.string(fromObject: dictionary?["name"])
        var fontSize = CGFloat(self.float(fromObject: dictionary?["size"]))
        
        fontSize += CGFloat(sizeAdjustment)
        
        if fontSize < 1.0 {
            fontSize = 15.0
        }
        
        var font: UIFont?
        if let fontName = fontName {
            if stringIsEmpty(s: fontName) {
                font = UIFont.systemFont(ofSize: fontSize)
            }
            else {
                font = UIFont(name: fontName, size: fontSize)
            }
        }

        if font == nil {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        return font!
    }
    
    public func point(forKey key: String) -> CGPoint {
        let dictionary = self.dictionary(forKey: key)
        return self.point(fromDictionary: dictionary)
    }
    
    private func point(fromDictionary dictionary: [String: Any]?) -> CGPoint {
        let x = CGFloat(self.float(fromObject: dictionary?["x"]))
        let y = CGFloat(self.float(fromObject: dictionary?["y"]))
        let point = CGPoint(x: x, y: y)
        return point
    }
    
    public func size(forKey key: String) -> CGSize {
        let dictionary = self.dictionary(forKey: key)
        return self.size(fromDictionary: dictionary)
    }
    
    private func size(fromDictionary dictionary: [String: Any]?) -> CGSize {
        let width = CGFloat(self.float(fromObject: dictionary?["width"]))
        let height = CGFloat(self.float(fromObject: dictionary?["height"]))
        let size = CGSize(width: width, height: height)
        return size
    }
    
    private func curve(fromObject object: Any?) -> UIView.AnimationOptions {
        guard let curveString = self.string(fromObject: object) else {
            return .curveEaseInOut
        }
        if stringIsEmpty(s: curveString) {
            return .curveEaseInOut
        }
        
        let lCurveString = curveString.lowercased()
        if lCurveString == "easeinout" {
            return .curveEaseInOut
        }
        else if lCurveString == "easeout" {
            return .curveEaseOut
        }
        else if lCurveString == "easein" {
            return .curveEaseIn
        }
        else if lCurveString == "linear" {
            return .curveLinear
        }
        return .curveEaseInOut
    }
    
    public func animationSpecifier(forKey key: String) -> AnimationSpecifier? {
        let animationSpecifier = AnimationSpecifier()
        
        guard let animationDictionary = self.dictionary(forKey: key) else {
            return nil
        }
        
        animationSpecifier.duration = self.timeInterval(fromObject: animationDictionary["duration"])
        animationSpecifier.delay = self.timeInterval(fromObject: animationDictionary["delay"])
        animationSpecifier.curve = self.curve(fromObject: animationDictionary["curve"])
        
        return animationSpecifier
    }
    
    func textCaseTransform(forKey key: String) -> TextCaseTransform {
        let s = self.string(forKey: key)
        return self.textCaseTransform(fromString: s)
    }
    
    private func textCaseTransform(fromString string: String?) -> TextCaseTransform {
        guard let string = string else {
            return .none
        }
        if string.caseInsensitiveCompare("lowercase") == .orderedSame {
            return .lower
        }
        else if string.caseInsensitiveCompare("uppercase") == .orderedSame {
            return .upper
        }
        return .none
    }
    
    public func viewSpecifier(forKey key: String) -> ViewSpecifier? {
        guard let cachedSpecifier = self.viewSpecifierCache.object(forKey: key as NSString) else {
            let dictionary = self.dictionary(forKey: key)
            let viewSpecifier = self.viewSpecifier(fromDictionary: dictionary)
            if let viewSpecifier = viewSpecifier {
                self.viewSpecifierCache.setObject(viewSpecifier, forKey: key as NSString)
            }
            return viewSpecifier
        }
        return cachedSpecifier
    }
    
    private func viewSpecifier(fromDictionary dictionary: [String: Any]?) -> ViewSpecifier? {
        guard let dictionary = dictionary else {
            return nil
        }
        
        let viewSpecifier = ViewSpecifier()
        
        let sizeDictionary = self.dictionary(fromObject: dictionary["size"])
        viewSpecifier.size = self.size(fromDictionary: sizeDictionary)
        
        let positionDictionary = self.dictionary(fromObject: dictionary["position"])
        viewSpecifier.position = self.point(fromDictionary: positionDictionary)
        
        if let backgroundColorDictionary = self.dictionary(fromObject: dictionary["backgroundColor"]) {
            viewSpecifier.backgroundColor = self.color(fromDictionary: backgroundColorDictionary)
        }
        
        if let highlightedBackgroundColorDictionary = self.dictionary(fromObject: dictionary["highlightedBackgroundColor"]) {
            viewSpecifier.highlightedBackgroundColor = self.color(fromDictionary: highlightedBackgroundColorDictionary)
        }
        
        let edgeInsetsDictionary = self.dictionary(fromObject: dictionary["padding"])
        viewSpecifier.padding = self.edgeInsets(fromDictionary: edgeInsetsDictionary)
        
        return viewSpecifier
    }
    
    public func navigationBarSpecifier(forKey key: String) -> NavigationBarSpecifier? {
        return self.navigationBarSpecifier(forKey: key, sizeAdjustment:0)
    }
    
    public func navigationBarSpecifier(forKey key: String, sizeAdjustment: Float) -> NavigationBarSpecifier? {
        guard let cachedSpecifier = self.navigationBarSpecifierCache.object(forKey: key as NSString) else {
         
            let navigationBarSpecifier = NavigationBarSpecifier()
            guard let dictionary = self.dictionary(forKey: key) else {
                return nil
            }
            
            if let popoverBackgroundColorDictionary = self.dictionary(fromObject: dictionary["popoverBackgroundColor"]) {
                navigationBarSpecifier.popoverBackgroundColor = self.color(fromDictionary: popoverBackgroundColorDictionary)
            }
            
            if let barColorDictionary = self.dictionary(fromObject: dictionary["barColor"]) {
                navigationBarSpecifier.barColor = self.color(fromDictionary: barColorDictionary)
            }
            
            if let tintColorDictionary = self.dictionary(fromObject: dictionary["tintColor"]) {
                navigationBarSpecifier.tintColor = self.color(fromDictionary: tintColorDictionary)
            }
            
            navigationBarSpecifier.titleLabelSpecifier = self.textLabelSpecifier(fromDictionary: dictionary["titleLabel"] as? [String : Any], sizeAdjustment: sizeAdjustment)
            
            navigationBarSpecifier.buttonsLabelSpecifier = self.textLabelSpecifier(fromDictionary: dictionary["buttonsLabel"] as? [String : Any], sizeAdjustment: sizeAdjustment)
            
            // always translucent by default
            let translucent = !self.bool(forObject: dictionary["disableTranslucency"])
            navigationBarSpecifier.translucent = translucent
            
            self.navigationBarSpecifierCache.setObject(navigationBarSpecifier, forKey: key as NSString)
            return navigationBarSpecifier
        }
        return cachedSpecifier
    }
    
    public func textLabelSpecifier(forKey key: String) -> TextLabelSpecifier? {
        return self.textLabelSpecifier(forKey: key, sizeAdjustment: 0)
    }
    
    public func textLabelSpecifier(forKey key: String, sizeAdjustment: Float) -> TextLabelSpecifier? {
        let cacheKey = key.appendingFormat("_%.2f", sizeAdjustment)
        guard let cachedSpecifier = self.textLabelSpecifierCache.object(forKey: cacheKey as NSString) else {
            let dictionary = self.dictionary(forKey: key)
            let labelSpecifier = self.textLabelSpecifier(fromDictionary: dictionary, sizeAdjustment: sizeAdjustment)
            if let labelSpecifier = labelSpecifier {
                self.textLabelSpecifierCache.setObject(labelSpecifier, forKey: cacheKey as NSString)
            }
            return labelSpecifier
        }
        return cachedSpecifier
    }
    
    public func textLabelSpecifier(fromDictionary dictionary: [String: Any]?, sizeAdjustment: Float) -> TextLabelSpecifier? {
        
        guard let dictionary = dictionary else {
            return nil
        }
        
        let labelSpecifier = TextLabelSpecifier()
        
        let fontDictionary = self.dictionary(fromObject: dictionary["font"])
        labelSpecifier.font = self.font(fromDictionary: fontDictionary, sizeAdjustment: sizeAdjustment)
        
        let sizeDictionary = self.dictionary(fromObject: dictionary["size"])
        labelSpecifier.size = self.size(fromDictionary: sizeDictionary)
        
        labelSpecifier.sizeToFit = self.bool(forObject: dictionary["sizeToFit"])
        
        let positionDictionary = self.dictionary(fromObject: dictionary["position"])
        labelSpecifier.position = self.point(fromDictionary: positionDictionary)
        
        if let numberOfLines = dictionary["numberOfLines"] {
            labelSpecifier.numberOfLines = self.integer(fromObject: numberOfLines)
        }
        else {
            labelSpecifier.numberOfLines = 1
        }
        
        labelSpecifier.paragraphSpacing = self.float(fromObject: dictionary["paragraphSpacing"])
        labelSpecifier.paragraphSpacingMultiple = self.float(fromObject: dictionary["paragraphSpacingMultiple"])
        labelSpecifier.paragraphSpacingBefore = self.float(fromObject: dictionary["paragraphSpacingBefore"])
        labelSpecifier.paragraphSpacingBeforeMultiple = self.float(fromObject: dictionary["paragraphSpacingBeforeMultiple"])
        
        let alignmentString = self.string(fromObject: dictionary["alignment"])
        labelSpecifier.alignment = self.textAlignment(fromObject: alignmentString)
        
        let lineBreakString = self.string(fromObject: dictionary["lineBreakMode"])
        labelSpecifier.lineBreakMode = self.lineBreakMode(fromObject: lineBreakString)
        
        let textTransformString = self.string(fromObject: dictionary["textTransform"])
        labelSpecifier.textTransform = self.textCaseTransform(fromString: textTransformString)
        
        if let colorDictionary = self.dictionary(fromObject: dictionary["color"]) {
            labelSpecifier.color = self.color(fromDictionary: colorDictionary)
        }
        
        if let highlightedColorDictionary = self.dictionary(fromObject: dictionary["highlightedColor"]) {
            labelSpecifier.highlightedColor = self.color(fromDictionary: highlightedColorDictionary)
        }
        
        if let backgroundColorDictionary = self.dictionary(fromObject: dictionary["backgroundColor"]) {
            labelSpecifier.backgroundColor = self.color(fromDictionary: backgroundColorDictionary)
        }
        
        if let highlightedBackgroundColorDictionary = self.dictionary(fromObject: dictionary["highlightedBackgroundColor"]) {
            labelSpecifier.highlightedBackgroundColor = self.color(fromDictionary: highlightedBackgroundColorDictionary)
        }
        
        let edgeInsetsDictionary = self.dictionary(fromObject: dictionary["padding"])
        labelSpecifier.padding = self.edgeInsets(fromDictionary: edgeInsetsDictionary)
        
        let allAttributes = [
            NSFontAttributeName,
            NSForegroundColorAttributeName,
            NSBackgroundColorAttributeName,
            NSParagraphStyleAttributeName]
        labelSpecifier.attributes = labelSpecifier.attributes(forKeys: allAttributes)
        return labelSpecifier
    }
    
    public func dashedBorderSpecifier(forKey key: String) -> DashedBorderSpecifier? {
        guard let dictionary = self.dictionary(fromObject: key) else {
            return nil
        }
        
        let dashedBorderSpecifier = DashedBorderSpecifier()
        
        if let colorDictionary = self.dictionary(fromObject: dictionary["color"]) {
            dashedBorderSpecifier.color = self.color(fromDictionary: colorDictionary)
        }
        
        dashedBorderSpecifier.lineWidth = self.float(fromObject: dictionary["lineWidth"])
        dashedBorderSpecifier.cornerRadius = self.float(fromObject: dictionary["cornerRadius"])
        dashedBorderSpecifier.paintedSegmentLength = self.float(fromObject: dictionary["paintedSegmentLength"])
        dashedBorderSpecifier.spacingSegmentLength = self.float(fromObject: dictionary["spacingSegmentLength"])
        
        let edgeInsetsDictionary = self.dictionary(fromObject: dictionary["insets"])
        dashedBorderSpecifier.insets = self.edgeInsets(fromDictionary: edgeInsetsDictionary)
        
        return dashedBorderSpecifier
    }
    
    public func textAlignment(forKey key: String) -> NSTextAlignment {
        let obj = self.object(forKey: key)
        return self.textAlignment(fromObject: obj)
    }

    private func textAlignment(fromObject object: Any?) -> NSTextAlignment {
        var alignmentString = self.string(fromObject: object)
        if !stringIsEmpty(s: alignmentString) {
            alignmentString = alignmentString?.lowercased()
            if alignmentString == "left" {
                return .left
            }
            else if alignmentString == "right" {
                return .right
            }
            else if alignmentString == "justified" {
                return .justified
            }
            else if alignmentString == "natural" {
                return .natural
            }
        }
        return .left
    }
    
    public func lineBreakMode(forKey key: String) -> NSLineBreakMode {
        let obj = self.object(forKey: key)
        return self.lineBreakMode(fromObject: obj)
    }
    
    private func lineBreakMode(fromObject object: Any?) -> NSLineBreakMode {
        var linebreakString = self.string(fromObject: object)
        if !stringIsEmpty(s: linebreakString) {
            linebreakString = linebreakString?.lowercased()
            if linebreakString == "wordwrap" {
                return .byWordWrapping
            }
            else if linebreakString == "charwrap" {
                return .byCharWrapping
            }
            else if linebreakString == "clip" {
                return .byClipping
            }
            else if linebreakString == "truncatehead" {
                return .byTruncatingHead
            }
            else if linebreakString == "truncatetail" {
                return .byTruncatingTail
            }
            else if linebreakString == "truncatemiddle" {
                return .byTruncatingMiddle
            }
        }
        return .byTruncatingTail
    }
    
    public func statusBarStyle(forKey key: String) -> UIStatusBarStyle {
        let obj = self.object(forKey: key)
        return self.statusBarStyle(fromObject: obj)
    }
    
    private func statusBarStyle(fromObject object: Any?) -> UIStatusBarStyle {
        var statusBarStyleString = self.string(fromObject: object)
        if !stringIsEmpty(s: statusBarStyleString) {
            statusBarStyleString = statusBarStyleString?.lowercased()
            if statusBarStyleString == "darkcontent" {
                return .default
            }
            else if statusBarStyleString == "lightcontent" {
                return .lightContent
            }
        }
        return .default
    }
    
    public func keyboardAppearance(forKey key: String) -> UIKeyboardAppearance {
        let obj = self.object(forKey: key)
        return self.keyboardAppearance(fromObject: obj)
    }
    
    private func keyboardAppearance(fromObject object: Any?) -> UIKeyboardAppearance {
        var keyboardAppearanceString = self.string(fromObject: object)
        if !stringIsEmpty(s: keyboardAppearanceString) {
            keyboardAppearanceString = keyboardAppearanceString?.lowercased()
            if keyboardAppearanceString == "dark" {
                return .dark
            }
            else if keyboardAppearanceString == "light" {
                return .light
            }
        }
        return .default
    }
    
    // MARK: Other Public Helper Methods
    
    public func contains(key: String) -> Bool {
        guard let _ = self.themeDictionary[key] else {
            return false
        }
        return true
    }
    
    public func containsOrInherits(key: String) -> Bool {
        guard let _ = self.object(forKey: key) else {
            return false
        }
        return true
    }
    
    public func clearFontCache() {
        self.fontCache.removeAllObjects()
    }
    
    public func clearColorCache() {
        self.colorCache.removeAllObjects()
    }
    
    public func clearViewSpecifierCache() {
        self.viewSpecifierCache.removeAllObjects()
    }
    
    public func clearNavigationBarSpecifierCache() {
        self.navigationBarSpecifierCache.removeAllObjects()
    }
    
    public func clearTextLabelSpecifierCache() {
        self.textLabelSpecifierCache.removeAllObjects()
    }
}

public extension Theme {
    
    public func view(withViewSpecifierKey viewSpecifierKey: String) -> UIView {
        guard let viewSpecifier = self.viewSpecifier(forKey: viewSpecifierKey) else {
            fatalError("viewSpecifier is nil for key \(viewSpecifierKey)")
        }
        let frame = CGRect(origin: viewSpecifier.position, size: viewSpecifier.size)
        let view = UIView(frame: frame)
        view.backgroundColor = viewSpecifier.backgroundColor
        return view
    }
    
    public func label(withText text: String, specifierKey labelSpecifierKey: String) -> UILabel {
        return self.label(withText: text, specifierKey: labelSpecifierKey, sizeAdjustment: 0)
    }
    
    public func label(withText text: String, specifierKey labelSpecifierKey: String, sizeAdjustment: Float) -> UILabel {
        guard let textLabelSpecifier = self.textLabelSpecifier(forKey: labelSpecifierKey, sizeAdjustment: sizeAdjustment) else {
            fatalError("label is nil for key \(labelSpecifierKey)")
        }
        return textLabelSpecifier.label(withText: text)
    }
    
    public func animate(withAnimationSpecifierKey animationSpecifierKey: String, animations:@escaping (() -> ()), completion:@escaping ((_ finished: Bool) -> ())) {
        
        guard let animationSpecifier = self.animationSpecifier(forKey: animationSpecifierKey) else {
            fatalError("animation specifier is nil for key \(animationSpecifierKey)")
        }
        
        UIView.animate(withDuration: animationSpecifier.duration, delay: animationSpecifier.delay, options: animationSpecifier.curve, animations: animations, completion: completion)
    }
    
}

public class AnimationSpecifier {
    public var delay: TimeInterval = 0
    public var duration: TimeInterval = 0
    public var curve: UIView.AnimationOptions = .curveEaseInOut
}

public class ViewSpecifier {
    public var size = CGSize.zero
    public var position = CGPoint.zero
    public var backgroundColor: UIColor?
    public var highlightedBackgroundColor: UIColor?
    
    /** Not used when creating a view \c -viewWithViewSpecifierKey:. How padding
     affect the view to be interpreted by interested party. */
    public var padding = UIEdgeInsets.zero
}

public class NavigationBarSpecifier {
    
    public var translucent: Bool = false
    public var popoverBackgroundColor: UIColor?
    public var barColor: UIColor?
    public var tintColor: UIColor?
    public var titleLabelSpecifier: TextLabelSpecifier?
    public var buttonsLabelSpecifier: TextLabelSpecifier?
    public func apply(toNavigationBar navigationBar: UINavigationBar, containedInClass containingClass: UIAppearanceContainer.Type?) {
        
        if let barColor = self.barColor {
            navigationBar.barTintColor = barColor
        }
        if let tintColor = self.tintColor {
            navigationBar.tintColor = tintColor
        }
        
        navigationBar.isTranslucent = self.translucent
        
        if let titleLabelSpecifier = self.titleLabelSpecifier {
            let attributes = titleLabelSpecifier.attributes(forKeys: [
                NSFontAttributeName,
                NSForegroundColorAttributeName])
            navigationBar.titleTextAttributes = attributes
        }
        
        if let buttonsLabelSpecifier = self.buttonsLabelSpecifier {
            let attributes = buttonsLabelSpecifier.attributes(forKeys: [
                NSFontAttributeName,
                NSForegroundColorAttributeName])
            if let containingClass = containingClass {
                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self, containingClass]).setTitleTextAttributes(attributes, for: .normal)
            }
            else {
                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes(attributes, for: .normal)
            }
        }
    }
}

public class TextLabelSpecifier {
    
    var font: UIFont?
    var size = CGSize.zero
    /** If YES, \c size should be ignored when creating a text label from it */
    var sizeToFit: Bool = false
    var position = CGPoint.zero
    /** Default: 1 (single line) */
    var numberOfLines: Int = 1
    
    var paragraphSpacing: Float = 0
    var paragraphSpacingBefore: Float = 0
    /// If multiple is > 0, takes precedence over paragraphSpacing
    var paragraphSpacingMultiple: Float = 0
    /// If multiple is > 0, takes precedence over paragraphSpacingBefore
    var paragraphSpacingBeforeMultiple: Float = 0
    
    var alignment: NSTextAlignment = .left
    var lineBreakMode: NSLineBreakMode = .byWordWrapping
    var textTransform: TextCaseTransform = .none
    var color: UIColor?
    var highlightedColor: UIColor?
    var backgroundColor: UIColor?
    var highlightedBackgroundColor: UIColor?
    
    /** Not used when creating a view \c -labelWithText:specifierKey:sizeAdjustment:
     How padding affect the text label to be interpreted by interested party. */
    var padding: UIEdgeInsets?
    
    /** Attributes representing the font, color, backgroundColor, alignment and lineBreakMode */
    var attributes: [String: Any]?
    
    func label(withText text: String) -> UILabel {
        let frame = CGRect(origin: self.position, size: self.size)
        return self.label(withText: text, frame: frame)
    }
    
    func label(withText text: String, frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        self.apply(toLabel: label, withText: text)
        return label
    }
    
    func transform(text: String) -> String {
        var transformedText: String
        switch self.textTransform {
        case .upper:
            transformedText = text.uppercased()
            break
        case .lower:
            transformedText = text.lowercased()
            break
        case .none:
            transformedText = text
            break
        }
        return transformedText
    }
    
    func attributedString(withText text: String) -> NSAttributedString {
        let allAttributes = self.attributes(forKeys: [
            NSFontAttributeName,
            NSForegroundColorAttributeName,
            NSBackgroundColorAttributeName,
            NSParagraphStyleAttributeName])
        return self.attributedString(withText: text, attributes: allAttributes)
    }
    
    func attributedString(withText text: String, attributes: [String: Any]) -> NSAttributedString {
        let transformedText = self.transform(text: text)
        return NSAttributedString(string: transformedText, attributes: attributes)
    }
    
    func fontAndColorAttributes() -> [String: Any] {
        return self.attributes(forKeys: [
            NSFontAttributeName,
            NSForegroundColorAttributeName,
            NSBackgroundColorAttributeName])
    }
    
    func attributes(forKeys keys: [String]) -> [String: Any] {
        var textAttributes: [String: Any] = [:]
        for key in keys {
            if key == NSParagraphStyleAttributeName {
                if let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
                    
                    paragraphStyle.lineBreakMode = self.lineBreakMode
                    paragraphStyle.alignment = self.alignment
                    
                    if self.paragraphSpacingMultiple>0, let font = self.font {
                        paragraphStyle.paragraphSpacing = font.pointSize * CGFloat(self.paragraphSpacingMultiple)
                    }
                    else if self.paragraphSpacing>0 {
                        paragraphStyle.paragraphSpacing = CGFloat(paragraphSpacing)
                    }
                    else if self.paragraphSpacingBeforeMultiple>0, let font = self.font {
                        paragraphStyle.paragraphSpacing = font.pointSize * CGFloat(self.paragraphSpacingBeforeMultiple)
                    }
                    else if self.paragraphSpacingBefore>0 {
                        paragraphStyle.paragraphSpacing = CGFloat(paragraphSpacingBefore)
                    }
                    textAttributes[key] = paragraphStyle
                }
            }
            else if key == NSFontAttributeName {
                if let font = self.font {
                    textAttributes[key] = font
                }
            }
            else if key == NSForegroundColorAttributeName {
                if let color = self.color {
                    textAttributes[key] = color
                }
            }
            else if key == NSBackgroundColorAttributeName {
                if let backgroundColor = self.backgroundColor {
                    textAttributes[key] = backgroundColor
                }
            }
            else {
                assertionFailure("Invalid key \(key) to obtain attribute for")
            }
        }
        
        return textAttributes
    }
    
    func apply(toLabel label: UILabel) {
        self.apply(toLabel: label, withText: nil)
    }
    
    func apply(toLabel label: UILabel, withText text: String?) {
        if let text = text {
            label.text = self.transform(text: text)
        }
        if let font = self.font {
            label.font = font
        }
        label.textAlignment = self.alignment
        label.numberOfLines = self.numberOfLines
        if let color = self.color {
            label.textColor = color
        }
        if let backgroundColor = self.backgroundColor {
            label.backgroundColor = backgroundColor
        }
        if self.sizeToFit {
            label.sizeToFit()
        }
    }
}

public class DashedBorderSpecifier {
    var lineWidth: Float = 0
    var color: UIColor?
    var cornerRadius: Float = 0
    var paintedSegmentLength: Float = 0
    var spacingSegmentLength: Float = 0
    var insets: UIEdgeInsets = .zero
}


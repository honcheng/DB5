//
//  Theme+watchOS.swift
//  CurrencyConverter_watchOS
//
//  Created by Hon Cheng Muh on 13/10/18.
//  Copyright © 2018 Clean Shaven Apps Pte. Ltd. All rights reserved.
//

import WatchKit
import UIKit

private enum WatchScreen {
    case s38mm
    case s40mm
    case s42mm
    case s44mm
    case unknown
    
    private static func screen(with size: CGSize) -> WatchScreen {
        if size.equalTo(CGSize(width: 272/2, height: 340/2)) {
            return .s38mm
        }
        else if size.equalTo(CGSize(width: 324/2, height: 394/2)) {
            return .s40mm
        }
        else if size.equalTo(CGSize(width: 312/2, height: 390/2)) {
            return .s42mm
        }
        else if size.equalTo(CGSize(width: 368/2, height: 448/2)) {
            return .s44mm
        }
        else {
            return .unknown
        }
    }
    
    static func currentScreen() -> WatchScreen {
        let currentDevice = WKInterfaceDevice.current()
        let bounds = currentDevice.screenBounds
        let watchScreen = WatchScreen.screen(with: bounds.size)
        return watchScreen
    }
    
    var fontSizeKey: String {
        get {
            switch self {
            case .s38mm:
                return "size38mm"
            case .s40mm:
                return "size40mm"
            case .s42mm:
                return "size42mm"
            case .s44mm:
                return "size44mm"
            default:
                return "size"
            }
        }
    }
}

extension Theme {

    public func font(forKey key:String) -> UIFont {
        let cacheKey = key
        guard let cachedFont = self.fontCache.object(forKey: cacheKey as NSString) else {
            let fontDictionary = self.dictionary(forKey: key)
            let font = self.font(fromDictionary: fontDictionary)
            self.fontCache.setObject(font, forKey: cacheKey as NSString)
            return font
        }
        return cachedFont
    }
    
    internal func font(fromDictionary dictionary: [String: Any]?) -> UIFont {

        let watchScreen = WatchScreen.currentScreen()
        var fontSize = CGFloat(self.float(fromObject: dictionary?[watchScreen.fontSizeKey]))
        let weight = self.string(fromObject: dictionary?["weight"])
        
        if fontSize < 1.0 {
            fontSize = 15.0
        }
        
        var fontWeight: UIFont.Weight
        if weight == "medium" {
            fontWeight = .medium
        }
        else if weight == "semibold" {
            fontWeight = .semibold
        }
        else if weight == "black" {
            fontWeight = .black
        }
        else if weight == "bold" {
            fontWeight = .bold
        }
        else if weight == "heavy" {
            fontWeight = .heavy
        }
        else if weight == "light" {
            fontWeight = .light
        }
        else if weight == "thin" {
            fontWeight = .thin
        }
        else if weight == "ultraLight" {
            fontWeight = .ultraLight
        }
        else {
            fontWeight = .regular
        }
        
        let font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return font
    }
}

class NavigationBarSpecifier {
    
}

class TextLabelSpecifier {
    
}

//
//  ThemeLoader.swift
//  DB5Demo-Swift
//
//  Created by Hon Cheng Muh on 12/1/17.
//  Copyright © 2017 Clean Shaven Apps Pte. Ltd. All rights reserved.
//

import UIKit

public class ThemeLoader {
    private(set) var defaultTheme: Theme!
    private(set) var themes: [Theme] = []
    
    public init?() {
        guard let themesFilePath = Bundle.main.path(forResource: "DB5", ofType: "plist") else {
            return nil
        }
        guard let themesDictionary = NSDictionary(contentsOfFile: themesFilePath) else {
            return nil
        }
        
        var themes: [Theme] = []
        for key in themesDictionary.allKeys {
            if let themeDictionary = themesDictionary[key] as? [String: Any], let key = key as? String {
                if let theme = Theme(name: key, themeDictionary: themeDictionary) {
                    if key.lowercased() == "default" {
                        self.defaultTheme = theme
                    }
                    themes.append(theme)
                }
            }
        }
        
        /*All themes inherit from the default theme.*/
        for oneTheme in themes {
            if oneTheme != self.defaultTheme {
                oneTheme.parentTheme = defaultTheme
            }
        }
        
        self.themes = themes
    }
    
    public func theme(named themeName: String) -> Theme? {
        
        for oneTheme in self.themes {
            if themeName == oneTheme.name {
                return oneTheme
            }
        }
        return nil
    }
}

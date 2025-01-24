//
//  Theme.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit

struct Theme {
    struct Colors {
        static let primary = UIColor(hex: "#3566B6") // Blue
        static let secondary = UIColor(hex: "#04C793") // Green
        static let tertiary = UIColor(hex: "#FE5E41") // Orange
        static let text = UIColor.white
        static let darkText = UIColor(hex: "#585858")
        static let subheading = UIColor.white.withAlphaComponent(0.8)
        static let placeholder = UIColor(hex: "#BABABA")
        static let darkBackground = UIColor(hex: "#2B5498") //Theme.Colors.primary.darken(by: 0.2)
        static let textfieldBackground = UIColor(hex: "#E6E6E6")
        static let separatorColor = UIColor(hex: "#1b417d")
    }
    
    struct Fonts {
        static let defaultFontSize: CGFloat = 16
        static let placeholderFontSize: CGFloat = 28.0
        
        static let mainFontName = "Futura"
        static let secondaryFontName = "Futura"
        
        enum Style {
            case main(weight: SecondaryFontWeight)
            case secondary(weight: SecondaryFontWeight)

            var fontName: String {
                switch self {
                case .main:
                    return mainFontName
                case .secondary:
                    return secondaryFontName
                }
            }

            var defaultSize: CGFloat {
                return Fonts.defaultFontSize
            }

            var font: UIFont {
                switch self {
                case .main(let weight):
                    let weightName: String
                    switch weight {
                    case .light: weightName = "-Medium"
                    case .regular: weightName = "-Medium"
                    case .medium: weightName = "-Medium"
                    case .demiBold: weightName = "-Bold"
                    case .bold: weightName = "-Bold"
                    case .heavy: weightName = "-Bold"
                    }
                    return UIFont(name: fontName + weightName, size: defaultSize) ?? .systemFont(ofSize: defaultSize)
                case .secondary(let weight):
                    let weightName: String
                    switch weight {
                    case .light: weightName = "-Medium"
                    case .regular: weightName = "-Medium"
                    case .medium: weightName = "-Medium"
                    case .demiBold: weightName = "-Bold"
                    case .bold: weightName = "-Bold"
                    case .heavy: weightName = "-Bold"
                    }
                    return UIFont(name: fontName + weightName, size: defaultSize) ?? .systemFont(ofSize: defaultSize)
                }
            }
        }
        
        enum SecondaryFontWeight {
            case light
            case regular
            case medium
            case demiBold
            case bold
            case heavy
        }
    }
}

extension UIFont {
    func withDynamicSize(_ fontSize: CGFloat) -> UIFont {
        guard let screenHeight = UIScreen.current?.bounds.height else {
            return withSize(fontSize)
        }
        
        let min = fontSize - (fontSize * 0.25)
        let adjustedSize = max(screenHeight * 0.00118 * fontSize, min)
        return withSize(adjustedSize)
    }
}

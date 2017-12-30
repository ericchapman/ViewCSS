//
//  UIView+ViewCSS.swift
//  FBSnapshotTestCase
//
//  Created by Eric Chapman on 12/29/17.
//

import Foundation

protocol ViewCSSProtocol {
    func setCSSBackgroundColor(_ color: UIColor)
    func setCSSTintColor(_ color: UIColor)
    func setCSSBorderRadius(_ radius: CGFloat)
}

protocol ViewCSSTextProtocol: ViewCSSProtocol {
    func setCSSTextColor(_ color: UIColor)
    func setCSSFont(_ font: UIFont)
    func setCSSTextAlignment( _ alignment: NSTextAlignment)
}

extension UIView: ViewCSSProtocol {
    func setCSSBackgroundColor(_ color: UIColor) { self.backgroundColor = color }
    func setCSSTintColor(_ color: UIColor) { self.tintColor = color }
    func setCSSBorderRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}

extension UILabel: ViewCSSTextProtocol {
    func setCSSTextColor(_ color: UIColor) { self.textColor = color }
    func setCSSFont(_ font: UIFont) { self.font = font }
    func setCSSTextAlignment( _ alignment: NSTextAlignment) { self.textAlignment = alignment }
}

extension UITextField: ViewCSSTextProtocol {
    func setCSSTextColor(_ color: UIColor) { self.textColor = color }
    func setCSSFont(_ font: UIFont) { self.font = font }
    func setCSSTextAlignment( _ alignment: NSTextAlignment) { self.textAlignment = alignment }
}

extension UITextView: ViewCSSTextProtocol {
    func setCSSTextColor(_ color: UIColor) { self.textColor = color }
    func setCSSFont(_ font: UIFont) { self.font = font }
    func setCSSTextAlignment( _ alignment: NSTextAlignment) { self.textAlignment = alignment }
}

extension UIButton: ViewCSSTextProtocol {
    func setCSSTextColor(_ color: UIColor) { self.setTitleColor(color, for: .normal) }
    func setCSSFont(_ font: UIFont) { self.titleLabel?.font = font }
    func setCSSTextAlignment( _ alignment: NSTextAlignment) {
        if alignment == .left {
            self.contentHorizontalAlignment = .left
        }
        else if alignment == .right {
            self.contentHorizontalAlignment = .right
        }
        else {
            self.contentHorizontalAlignment = .center
        }
    }
}

private var CSSKeyObjectHandle: UInt8 = 0
public extension UIView {
    
    private var cssKey: String? {
        get {
            return objc_getAssociatedObject(self, &CSSKeyObjectHandle) as? String
        }
        set {
            objc_setAssociatedObject(self, &CSSKeyObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func css(style: String?) { self.css(style: style, class: nil) }
    func css(class klass: String?) { self.css(style: nil, class: klass) }
    func css(class klass: String?, style: String?) { self.css(style: style, class: klass) }
    
    func css(style: String?, class klass: String?) {
        
        // Set the style for this object
        self.cssKey = ViewCSSManager.shared.getCacheKey(object: self, style: style, class: klass)
        let config = ViewCSSManager.shared.getConfig(object: self, style: style, class: klass)
        
        // COLORS
        // If it is a UIView, check for main color first, else just background color
        if let color = config.backgroundColor {
            self.setCSSBackgroundColor(color)
        }
        
        if let color = config.tintColor {
             self.setCSSTintColor(color)
        }
        
        // CORNER RADIUS
        if config.borderRadius != nil {
            self.setCSSBorderRadius(config.borderRadius!)
        }
        
        // Check if it responds to text protocol
        if let textProtocol = self as? ViewCSSTextProtocol {
            let defaultFontSize: CGFloat = 15.0
            
            // Set the color
            if config.color != nil {
                textProtocol.setCSSTextColor(config.color!)
            }
            
            // Set the size and the weight
            if #available(iOS 8.2, *) {
                if config.fontSize != nil || config.fontWeight != nil {
                    let scaledFontSize = round(15.0 * (config.fontSize ?? 1.0))
                    if config.fontWeight != nil {
                        textProtocol.setCSSFont(UIFont.systemFont(ofSize: scaledFontSize, weight: config.fontWeight!))
                    }
                    else {
                        textProtocol.setCSSFont(UIFont.systemFont(ofSize: scaledFontSize))
                    }
                }
            }
            else {
                if config.fontSize != nil {
                    let scaledFontSize = round(defaultFontSize * config.fontSize!)
                    textProtocol.setCSSFont(UIFont.systemFont(ofSize: scaledFontSize))
                }
            }

            // Set the alignment
            if let textAlign = config.textAlign {
                textProtocol.setCSSTextAlignment(textAlign)
            }
        }
    }
    
    func getCSS() -> ViewCSSStyleConfig? {
        if let cacheKey = self.cssKey {
            return ViewCSSManager.shared.getConfig(cacheKey: cacheKey)
        }
        return nil
    }
    
}

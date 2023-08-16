//
//  View+Ext.swift
//  Place Picker UIKit
//
//  Created by Rafli on 13/08/23.
//

import Foundation
import UIKit


extension UIView {
    
    //MARK: - Design
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var isCircular: Bool {
        get {
            return layer.cornerRadius == min(bounds.width, bounds.height) / 2.0
        }
        set {
            if newValue {
                // Calculate the radius for the circular view
                let radius = min(bounds.width, bounds.height) / 2.0
                
                // Set the corner radius to make the view circular
                layer.cornerRadius = radius
                clipsToBounds = true
            } else {
                // Reset the corner radius to make the view rectangular
                layer.cornerRadius = 0.0
                clipsToBounds = false
            }
        }
    }
    
    @IBInspectable var topLeftCornerRadius: CGFloat {
        get {
            return layer.maskedCorners.contains(.layerMinXMinYCorner) ? layer.cornerRadius : 0.0
        }
        set {
            layer.cornerRadius = newValue
            var maskedCorners: CACornerMask = []
            if newValue > 0 {
                maskedCorners.insert(.layerMinXMinYCorner)
            }
            if topRightCornerRadius > 0 {
                maskedCorners.insert(.layerMaxXMinYCorner)
            }
            if bottomLeftCornerRadius > 0 {
                maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if bottomRightCornerRadius > 0 {
                maskedCorners.insert(.layerMaxXMaxYCorner)
            }
            layer.maskedCorners = maskedCorners
        }
    }
    
    @IBInspectable var topRightCornerRadius: CGFloat {
        get {
            return layer.maskedCorners.contains(.layerMaxXMinYCorner) ? layer.cornerRadius : 0.0
        }
        set {
            layer.cornerRadius = newValue
            var maskedCorners: CACornerMask = []
            if topLeftCornerRadius > 0 {
                maskedCorners.insert(.layerMinXMinYCorner)
            }
            if newValue > 0 {
                maskedCorners.insert(.layerMaxXMinYCorner)
            }
            if bottomLeftCornerRadius > 0 {
                maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if bottomRightCornerRadius > 0 {
                maskedCorners.insert(.layerMaxXMaxYCorner)
            }
            layer.maskedCorners = maskedCorners
        }
    }
    
    @IBInspectable var bottomLeftCornerRadius: CGFloat {
        get {
            return layer.maskedCorners.contains(.layerMinXMaxYCorner) ? layer.cornerRadius : 0.0
        }
        set {
            layer.cornerRadius = newValue
            var maskedCorners: CACornerMask = []
            if topLeftCornerRadius > 0 {
                maskedCorners.insert(.layerMinXMinYCorner)
            }
            if topRightCornerRadius > 0 {
                maskedCorners.insert(.layerMaxXMinYCorner)
            }
            if newValue > 0 {
                maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if bottomRightCornerRadius > 0 {
                maskedCorners.insert(.layerMaxXMaxYCorner)
            }
            layer.maskedCorners = maskedCorners
        }
    }
    
    @IBInspectable var bottomRightCornerRadius: CGFloat {
        get {
            return layer.maskedCorners.contains(.layerMaxXMaxYCorner) ? layer.cornerRadius : 0.0
        }
        set {
            layer.cornerRadius = newValue
            var maskedCorners: CACornerMask = []
            if topLeftCornerRadius > 0 {
                maskedCorners.insert(.layerMinXMinYCorner)
            }
            if topRightCornerRadius > 0 {
                maskedCorners.insert(.layerMaxXMinYCorner)
            }
            if bottomLeftCornerRadius > 0 {
                maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if newValue > 0 {
                maskedCorners.insert(.layerMaxXMaxYCorner)
            }
            layer.maskedCorners = maskedCorners
        }
    }
    
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else { return nil }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var setShadow: Bool {
        get {
            return layer.shadowOpacity > 0
        }
        set {
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "GreyLightColor")?.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: -1, height: 1)
            layer.shadowRadius = 10
            
            layer.shadowPath = UIBezierPath(rect: bounds).cgPath
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        }
    }
}

extension UIView {
    //MARK: - Function
    func addTapGesture(action: @escaping () -> Void) {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGesture)
        associatedAction = action
    }
    
    @objc private func handleTapGesture() {
        associatedAction?()
    }
    
    private var associatedAction: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.associatedAction) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.associatedAction, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private struct AssociatedKeys {
        static var associatedAction = "associatedAction"
    }
    
    func makeCircle() {
        let radius = min(self.frame.size.width, self.frame.size.height) / 2.0
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}

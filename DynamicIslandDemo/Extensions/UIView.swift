//
//  UIView.swift
//  DynamicIslandDemo
//
//  Created by Сергей Штейман on 07.03.2024.
//

import UIKit


extension UIView {
    
    func myAddSubView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
    
    func myAddSubViews(from array: [UIView]) {
        for view in array {
            myAddSubView(view)
        }
    }
    
    func addGradientLayer(with view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.cyan.cgColor,
                           UIColor.white.cgColor]
        gradient.locations = [0, 1]
        gradient.cornerRadius = 20.0
        self.layer.addSublayer(gradient)
    }
    
    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    // MARK: getSafeArea
    /// Returns the safe area insets for the current view
    func getSafeArea() -> UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

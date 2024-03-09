//
//  View.swift
//  DynamicIslandDemo
//
//  Created by Сергей Штейман on 09.03.2024.
//

import SwiftUI


extension View {
    
    // MARK: getSafeArea
    // Returns the safe area insets for the current view
    func getSafeArea() -> UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

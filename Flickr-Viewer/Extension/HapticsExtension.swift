//
//  HapticsExtension.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-16.
//

import UIKit

struct Haptics {
    
    static func impact(forStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
        var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: style)
        generator?.impactOccurred()
        generator = nil
    }
    
    static func notification(forType type: UINotificationFeedbackGenerator.FeedbackType) {
        var generator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
        generator?.notificationOccurred(type)
        generator = nil
    }
    
    static func selection() {
        var generator: UISelectionFeedbackGenerator? = UISelectionFeedbackGenerator()
        generator?.selectionChanged()
        generator = nil
    }
}

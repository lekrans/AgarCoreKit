//
//  AgarHapticManager.swift
//  AgarCoreKit
//
//  Created by Michael Lekrans on 2025-07-12.
//

// AgarCoreKit Package Structure
// This is the structure and example setup for a Swift Package with DocC support

// 1. Folder structure (inside Sources folder):
//
// AgarCoreKit/
// ├── AgarCoreKit.swift (optional umbrella file)
// ├── Haptics/
// │   └── HapticManager.swift
// ├── Audio/
// │   └── AudioManager.swift
// ├── Animation/
// │   └── AnimationManager.swift
// ├── Extensions/
// │   └── View+Shake.swift
// └── Resources/ (optional .ahap, .wav, etc.)
//
// Documentation/
// └── AgarCoreKit.docc/
//     ├── AgarCoreKit.md
//     └── tutorials/
//         └── CreatingHaptics.tutorial
//
// Tests/
// └── AgarCoreKitTests/
//     └── AgarCoreKitTests.swift

// Example HapticManager.swift


import CoreHaptics
import Foundation

/// A singleton manager for handling haptic feedback throughout the app or game.
@available(macOS 10.15, *)
public final class AgarHapticManager {
    private var engine: CHHapticEngine?
    
    
    /// The shared singleton instance.
    @MainActor public static let shared = AgarHapticManager()
    
    private init() {
        prepareHaptics()
    }
    
    /// Prepares and starts the Core Haptics engine.
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("[HapticManager] Failed to start engine: \(error.localizedDescription)")
        }
    }
    
    /// Plays a quick transient haptic event.
    /// - Parameters:
    ///   - intensity: A value between 0 and 1 representing the strength of the haptic.
    ///   - sharpness: A value between 0 and 1 representing the sharpness of the haptic.
    public func playTransient(intensity: Float = 1.0, sharpness: Float = 0.5) {
        guard let engine else { return }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: intensity),
                .init(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("[HapticManager] Playback error: \(error.localizedDescription)")
        }
    }
}

// Example extension in Extensions/View+Shake.swift

import SwiftUI

@available(macOS 10.15, *)
public extension View {
    /// Applies a shake animation effect to the view.
    func shakeEffect() -> some View {
        self.modifier(ShakeEffect())
    }
}

// ShakeEffect.swift (modifier used above)
@available(macOS 10.15, *)
public struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    public var animatableData: CGFloat
    
    public init(animatableData: CGFloat = 0) {
        self.animatableData = animatableData
    }
    
    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX:
                                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}


// Example DocC file: Documentation/AgarCoreKit.docc/AgarCoreKit.md
/*
 # AgarCoreKit
 
 A modular game utility library for audio, haptics, animation, and more.
 
 ## Topics
 
 ### Haptics
 - ``AgarHapticManager``
 
 ### Effects
 - ``View/shakeEffect()``
 */

// Example tutorial file: Documentation/AgarCoreKit.docc/tutorials/CreatingHaptics.tutorial
/*
 @Tutorials
 @Title Creating Custom Haptics
 
 Learn how to generate transient haptic effects using AgarCoreKit.
 
 @Intro
 AgarCoreKit helps you create simple, powerful feedback effects. This tutorial shows how to call a transient haptic event.
 
 @Section(step: 1) Playing a Transient Haptic
 ```swift
 AgarHapticManager.shared.playTransient(intensity: 0.8, sharpness: 0.6)
 ```
 */

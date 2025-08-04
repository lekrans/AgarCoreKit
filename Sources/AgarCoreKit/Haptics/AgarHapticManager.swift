//
//  HapticManager.swift
//  Agar_HapticSampler
//
//  Created by Michael Lekrans on 2025-07-11.
//

import CoreHaptics
import AVFoundation
import Foundation

public class AgarHapticManager {
    private var engine: CHHapticEngine?
    private var avEngine: AudioManager?
    
    public init() {
        prepareHaptics()
        prepareAudio()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Device does not support haptics")
            return
        }
        
        do {
            self.engine = try CHHapticEngine()
            
            // Handle unexpected stops
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason.rawValue)")
                self.engine = nil
                self.prepareHaptics()
            }
            
            engine?.resetHandler = {
                print("Haptic engine reset")
                self.prepareHaptics()
            }
            
            try engine?.start()
        } catch {
            print("❌ Failed to start haptic engine: \(error.localizedDescription)")
        }
    }
    
    private func prepareAudio() {
        avEngine = AudioManager()
    }
    
    
    
    
    public func playEvents(_ events: [CHHapticEvent]) {
        guard let engine = engine else { return }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Error: \(error)")
        }
    }
    
    public func playHapticSoundEvent(hapticSound: AgarHapticSound, rate: Double = 1.0) {
        guard let engine = engine, let avEngine = avEngine else { return }
        do {
            
            let pattern = try CHHapticPattern(events: hapticSound.events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            for sound in hapticSound.soundResources {
                avEngine.playModifiedSound(sound: sound)
            }
            
            try player.start(atTime: 0)
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    /// Simple default values for a click
    public enum clickStrength: Double {
        case weak = 0.3
        case medium = 0.5
        case strong = 1
    }
    
    
    /// Simple default value for a click's sharpness
    public enum clickSharpness: Double {
        case soft = 0.25
        case medium = 0.75
        case hard = 1
    }
    
    
    
    /// Play a click haptic
    ///
    /// This is meant to be used as a fast way to add a haptic to a button tap or the like
    /// - Parameters:
    ///   - strength: The strength of the click
    ///   - sharpness: The sharpness of the click
    public func click(strength: clickStrength = .medium, sharpness: clickSharpness = .medium) {
        let event = transientHaptic(intensity: Float(strength.rawValue), sharpness: Float(sharpness.rawValue))
        playEvents([event])
    }
    
    
    /// Convenience method for creating a transient CHHapticEvent
    func transientHaptic(intensity: Float, sharpness: Float, relativeTime: TimeInterval = 0) -> CHHapticEvent{
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: intensity),
                .init(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: relativeTime
        )
        return event
    }
    
    /// Convenience method for creating a continuous CHHapticEvent
    func continuousHaptic(intensity: Float, sharpness: Float, duration: TimeInterval = 1, relativeTime: TimeInterval = 0) -> CHHapticEvent{
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                .init(parameterID: .hapticIntensity, value: intensity),
                .init(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: relativeTime,
            duration: duration
        )
        return event
    }
    
    
    
}

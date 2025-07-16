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

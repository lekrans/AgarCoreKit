//
//  AgarHapticSound.swift
//  AgarCoreKit
//
//  Created by Michael Lekrans on 2025-07-16.
//
//


import CoreHaptics




/// *****************************************
//  MARK: - NormalizedHapticEvent
/// *****************************************
///
/// Template for CHHapticEvent with normalized (0-1) values
///
/// NormalizedHapticEvent is used as a base template for creating CHHapticEvent's by calling it's ``toCHHapticEvent(rate:totalDuration:)``
public struct AgarNormalizedHapticEvent {
    /// type of event: [.hapticTransient .hapticContinuous]
    var type: CHHapticEvent.EventType
    
    /// Strength of the event (0-1)
    var intensity : Float
    
    /// softness/sharpness of event (0-1)
    var sharpness: Float
    
    /// normalized start time (0-1) 0:beginning, 1:end
    var relativeTime: TimeInterval // 0.0-1.0
    
    /// Normalized duration within an event group or sequence (0-1)
    var duration: TimeInterval?
    
    /// Transform to `CHHapticEvent`
    ///
    /// - Parameters:
    ///   - rate: the rate the event should be adjusted to (1.0 normal speed, 0.5 = half, 2.0 = double)
    ///   - totalDuration: The total duration in seconds that this event is part of
    /// - Returns: A`CHHapticEvent` with relativeTime and duration adjusted ***denormalized*** from `NormalizedHapticEvent` based on the `rate` and `totalDuration`
    func toCHHapticEvent(rate: Double, totalDuration: TimeInterval) -> CHHapticEvent {
        if type == .hapticContinuous, duration == nil {
            print("Warning: CHHapticEvent.EventType.hapticContinuous requires duration, setting to 1.0")
        }
        
        let actualTime = relativeTime / rate
        let actualDuration = (duration ?? 1.0) * totalDuration / rate
        
        return CHHapticEvent(
            eventType: type,
            parameters: [
                .init(parameterID: .hapticIntensity, value: intensity),
                .init(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: actualTime,
            duration: actualDuration
        )
    }
}


/// *****************************************
//  MARK: - AgarHapticSoundDefinition
/// *****************************************

///  A container representing a sound/haptic  synced relation. events are defined with normalized relativeTime and duration to be able to calculate the real values
public struct AgarHapticSoundDefinition {
    var name: String
    var events: [AgarNormalizedHapticEvent]
    var soundResources: [AgarAudioResource]
    var duration: TimeInterval
    
    func buildCHHapticEvents(rate: Double = 1.0, totalDuration: TimeInterval) -> [CHHapticEvent] {
        events.map { $0.toCHHapticEvent(rate: rate, totalDuration: duration) }
    }
}


/// *****************************************
//  MARK: - AgarHapticSound
/// *****************************************

/// Combines haptic and sound to one synchronized entity
///
/// The ``HapticSound`` class combine the ``CHHapticEvent`` with  ``AgarSoundResource`` information to make it easier to **synchronize** sound and haptics.
///
///When ***initialized*** the  rate  of the sound/haptic can be adjusted by setting a value higher than 1.0 (increase speed) or less than 1.0 to lower the speed and the timings will be recalculated to still be in sync
public class AgarHapticSound {
    static func == (lhs: AgarHapticSound, rhs: AgarHapticSound) -> Bool {
        return lhs.id == rhs.id
    }
    
    // private
    private var def: AgarHapticSoundDefinition
    
    // public
    var id: UUID = UUID()
    var name: String {
        return def.name
    }
    
    public var events: [CHHapticEvent] = []
    public var soundResources: [AgarAudioResource] = []
    
    public var rate: Double = 1.0 {
        didSet {
            recalcTimings()
        }
    }
    
    
    init(def: AgarHapticSoundDefinition, rate: Double = 1.0 ) {
        self.def = def
        
        self.rate = rate
        recalcTimings()
    }
    
    /// recalculate the patterns and soundsource information in the AgarHapticSoundDefinition
    private func recalcTimings() {
        AgarHapticSound.recalcTimings(rate: self.rate, def: self.def, events: &self.events, soundResources: &self.soundResources)
    }
    
    /// Recalculate the relative times and durations in the events and souundResources based on the rate
    /// - Parameter rate: The rate/speed change  ( 1.0 = normal speed, 2.0 = twice as fast, 0.5 = half the speed)
    private static func recalcTimings(rate: Double = 1.0, def: AgarHapticSoundDefinition, events: inout [CHHapticEvent], soundResources: inout [AgarAudioResource]) {
        
        events = def.buildCHHapticEvents(rate: rate, totalDuration: def.duration)
        
        soundResources = []
        for (_, resource) in def.soundResources.enumerated() {
            let newSoundResource = AgarAudioResource(
                fileName: resource.fileName, volume: resource.volume, pitch: resource.pitch, rate: resource.rate * Float(rate), length: resource.length, relativeTime: resource.relativeTime
            )
            
            soundResources.append(newSoundResource)
        }
    }
}


/// *****************************************
//  MARK: - Haptics
/// *****************************************

/// Enum for  AgarHapticSoundDefinitionFunctions available
public enum Haptics: String, CaseIterable {
    case hydraulicDoor1
    case hydraulicDoor2
    case weaponItemSelected
}



/// *****************************************
//  MARK: - HapticSoundGenerator
/// *****************************************

/// Generate AgarHapticSound instances with generator function AgarHapticSoundDefinitionFunction injected
///
/// >Important:  For now the ``AgarHapticSoundDefinition`` are declared straight into the class. Later this will instead be a list so you could add/remove functions into this class or even import whole libraries with functions
public class HapticSoundGenerator {
    @MainActor static let shared = HapticSoundGenerator()
    
    init() {}
    
    
    
    /// Generate a ``AgarHapticSound`` from a generator method associated with the ``Haptics``  value and sets a start rate for the ``AgarHapticSound`` instance
    /// - Parameters:
    ///   - name: The name of the predefined event
    ///   - rate: The speed of the AgarHapticSound
    /// - Returns: An instance of ``AgarHapticSound``
    func generate(name: Haptics, rate: Double = 1.0) -> AgarHapticSound {
        guard rate != 0 else {
            fatalError("try to generate haptic with rate 0")
        }
        
        switch name {
        case .hydraulicDoor1: return AgarHapticSound(def: self.hydraulicDoor1(), rate: rate)
        case .hydraulicDoor2: return AgarHapticSound(def: self.hydraulicDoor2(), rate: rate)
        case .weaponItemSelected: return AgarHapticSound(def: self.weaponItemSelected(), rate: rate)
            
        }
    }
    
    
    
    // MARK: PreDefinedSounds
    
    /// A long industrial  hydraulic door open or close
    /// - Returns: ``AgarHapticSoundDefinition``
    func hydraulicDoor1() -> AgarHapticSoundDefinition {
        let soundResource = AS.construction.building.door.metal.heavy.hydraulic.sliding.opening
        let duration = soundResource.length
        
        let events: [AgarNormalizedHapticEvent] = [
            AgarNormalizedHapticEvent(type: .hapticTransient, intensity: 1, sharpness: 1, relativeTime: 0.0),
            AgarNormalizedHapticEvent(type: .hapticContinuous, intensity: 0.5, sharpness: 0.3, relativeTime: 0.0, duration: 1.0),
            AgarNormalizedHapticEvent(type: .hapticTransient, intensity: 1, sharpness: 1, relativeTime: 0.6)
        ]
        let soundResources = [soundResource]
        
        return  AgarHapticSoundDefinition(name: "HydraulicDoorOpen", events: events, soundResources: soundResources, duration: duration)
    }
    
    
    /// A longindustrial hydraulic door open or close
    /// - Returns: ``AgarHapticSoundDefinition``
    func hydraulicDoor2() -> AgarHapticSoundDefinition {
        let soundResource = AS.construction.building.door.metal.heavy.hydraulic.sliding.closing
        let duration = soundResource.length
        let events: [AgarNormalizedHapticEvent] = [
            AgarNormalizedHapticEvent(type: .hapticTransient, intensity: 0.7, sharpness: 0.3, relativeTime: 0.02),
            AgarNormalizedHapticEvent(type: .hapticContinuous, intensity: 0.5, sharpness: 0.5, relativeTime: 0, duration: 1.0 ),
            AgarNormalizedHapticEvent(type: .hapticTransient, intensity: 0.7, sharpness: 0.1, relativeTime: 0.9)
        ]
        let soundResources = [soundResource]
        
        return  AgarHapticSoundDefinition(name: "HydraulicDoorClose", events: events, soundResources: soundResources, duration: duration)
    }
    
    
    
    /// A swoosh effect + gun cocking
    /// - Returns: ``AgarHapticSoundDefinition``
    func weaponItemSelected() -> AgarHapticSoundDefinition {
        let gunCocking = AS.weapons.small.guns.cocking.short
        let swoosh = AS.effects.swooshes.short
        let duration = gunCocking.length
        
        let events: [AgarNormalizedHapticEvent] = [
            AgarNormalizedHapticEvent(type: .hapticTransient,intensity: 0.7, sharpness: 0.7, relativeTime: 0.04),
            AgarNormalizedHapticEvent(type: .hapticContinuous,intensity: 0.4, sharpness: 0.2, relativeTime: 0, duration: 0.5),
            AgarNormalizedHapticEvent(type: .hapticTransient, intensity: 1.0, sharpness: 1.0, relativeTime: 0.25)
        ]
        let soundResources = [gunCocking, swoosh]
        
        return  AgarHapticSoundDefinition(name: "WeaponItemSelected", events: events, soundResources: soundResources, duration: duration)
    }
}



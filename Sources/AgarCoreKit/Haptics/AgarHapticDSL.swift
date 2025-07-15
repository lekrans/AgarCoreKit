//
//  HapticDSL.swift
//  Agar_HapticSoundGenerator
//
//  Created by Michael Lekrans on 2025-07-15.
//


import CoreHaptics

// MARK: - Haptic Event DSL Enum


/// Simplifies the syntax for creating groups of ``CHHapticEvent``
///
/// To avoid large bloated codebase this DSL was created.
/// When creating groups of `CHHapticEvent`s it could easily look like this
/// ```swift
/// [CHHapticEvent(
/// eventType: .hapticTransient,
/// parameters: [
///     .init(parameterID: .hapticIntensity, value: 1.0),
///     .init(parameterID: .hapticSharpness, value: 1.0)
/// ],
/// relativeTime: 0),
/// CHHapticEvent(
/// eventType: .hapticContinuous,
/// parameters: [
///     .init(parameterID: .hapticIntensity, value: 0.4),
///     .init(parameterID: .hapticSharpness, value: 0.2)
/// ],
/// relativeTime: 0.1,
/// duration: 0.5),
/// CHHapticEvent(
/// eventType: .hapticTransient,
/// parameters: [
///     .init(parameterID: .hapticIntensity, value: 0.8),
///     .init(parameterID: .hapticSharpness, value: 0.3)
/// ],
/// relativeTime: 0.7)]
/// ```
/// Can now be expressed as:
/// ```swift
/// let CHEvents = HapticGroup {
/// transient(1.0, 1.0, at: 0.0)
/// continuous(0.5, 0.3, at: 0.0, duration: 1.0)
/// transient(1.0, 1.0, at: 0.6)}
/// ```
enum AgarHapticEventDSL {
    case transient(intensity: Float, sharpness: Float, time: TimeInterval)
    case continuous(intensity: Float, sharpness: Float, time: TimeInterval, duration: TimeInterval)
    
    func toCHHapticEvent() -> CHHapticEvent {
        switch self {
        case let .transient(i, s, t):
            return CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: i),
                    .init(parameterID: .hapticSharpness, value: s)
                ],
                relativeTime: t
            )
        case let .continuous(i, s, t, d):
            return CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: i),
                    .init(parameterID: .hapticSharpness, value: s)
                ],
                relativeTime: t,
                duration: d
            )
        }
    }
}

// MARK: - Static Convenience

extension AgarHapticEventDSL {
    static func transient(_ intensity: Float, _ sharpness: Float, at time: TimeInterval) -> Self {
        .transient(intensity: intensity, sharpness: sharpness, time: time)
    }
    
    static func continuous(_ intensity: Float, _ sharpness: Float, at time: TimeInterval, duration: TimeInterval) -> Self {
        .continuous(intensity: intensity, sharpness: sharpness, time: time, duration: duration)
    }
}

// MARK: - Result Builder

@resultBuilder
struct HapticGroupBuilder {
    public static func buildBlock(_ components: CHHapticEvent...) -> [CHHapticEvent] {
        components
    }
}

public func transient(_ intensity: Float, _ sharpness: Float, at time: TimeInterval = 0) -> CHHapticEvent {
    CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [
            .init(parameterID: .hapticIntensity, value: intensity),
            .init(parameterID: .hapticSharpness, value: sharpness)
        ],
        relativeTime: time
    )
}

public func continuous(
    _ intensity: Float,
    _ sharpness: Float,
    at time: TimeInterval = 0,
    duration: TimeInterval = 1.0
) -> CHHapticEvent {
    CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [
            .init(parameterID: .hapticIntensity, value: intensity),
            .init(parameterID: .hapticSharpness, value: sharpness)
        ],
        relativeTime: time,
        duration: duration
    )
}


// MARK: - DSL Entry Point

/// Creates a group of CHHapticEvent from declarative syntax.
func HapticGroup(@HapticGroupBuilder _ content: () -> [CHHapticEvent]) -> [CHHapticEvent] {
    content()
}


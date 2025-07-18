//
//  AgarSounds.swift
//  TheInstables
//
//  Created by Michael Lekrans on 2025-07-09.
//

/// =====================================================
///    module:          `AgarSounds.swift`
///    Author:            `Michael Lekrans`
///    shortDesc:      `Collection of Sounds`
///    description:     `Collection of Sounds ordered hierarchical`
/// =====================================================

import SpriteKit
import AVFoundation




public struct AgarSounds {
    // type of sound
    struct construction {
        struct building {
            struct door {
                struct metal {
                    struct heavy {
                        struct hydraulic {
                            struct sliding {
                                @MainActor static let opening = AgarAudioResource(fileName: "Resources/Sounds/hydraulic/hydraulic1.wav", length: 1.71)
                                @MainActor static let closing = AgarAudioResource(fileName: "AgarCoreKit/Resources/Sounds/hydraulic/hydraulic2.wav", length: 1.58)
                            } // sliding
                        } // hydraulic
                    } // heavy
                } // metal
                struct wood {
                    
                } // wood
            } // door
        } // Building
    } // Construction
    struct weapons {
        struct large {
            
        } // large
        struct medium {
            
        } // medium
        struct small {
            struct guns {
                struct cocking {
                    @MainActor static let long = AgarAudioResource(fileName: "cocking1.wav", length: 1.02)
                    @MainActor static let short = AgarAudioResource(fileName: "cocking2.wav", length: 0.79)
                } // cocking
            } // guns
            struct swords {
                
            } // swords
            struct spears {
                
            } // spears
            struct axes {
                
            } // axes
        } // small
    } // weapons
    struct effects {
        struct explosions {
            //            static let small = AgarSoundResource(fileName: "explosion1.wav", volume: 1.0, pitch: 1.0)
            //            static let medium = AgarSoundResource(fileName: "explosion2.wav", volume: 1.0, pitch: 1.0)
        } // explosions
        struct swooshes {
            @MainActor static let short = AgarAudioResource(fileName: "swoosh.flac", length: 0.58)
        } // Swooshes
    } // effects
}

typealias AS = AgarSounds


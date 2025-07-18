//
//  AgarSoundResource.swift
//  AgarCoreKit
//
//  Created by Michael Lekrans on 2025-07-16.
//

import Foundation


/// Audio information for an Audie Resource
public struct AgarAudioResource {
    public var fileName: String
    public var volume: Float = 1.0
    public var pitch: Float = 1.0
    public var rate: Float = 1.0
    public var length: TimeInterval
    public var relativeTime: TimeInterval = 0.0
}

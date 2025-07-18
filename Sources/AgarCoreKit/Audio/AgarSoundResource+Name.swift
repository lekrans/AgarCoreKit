//
//  AgarSoundResource+Name.swift
//  AgarCoreKit
//
//  Created by Michael Lekrans on 2025-07-16.
//

extension AgarAudioResource {
    /// FileName without extension
    public var name: String {
        return String(fileName.split(separator: ".").first ?? "")
    }
    
    /// File extension
    public var ext: String {
        return String(fileName.split(separator: ".").last ?? "")
    }

}

//
//  AgarSoundResource+Loading.swift
//  AgarCoreKit
//
//  Created by Michael Lekrans on 2025-07-16.
//

import Foundation


extension AgarAudioResource {
    
    /// *****************************************
    //  MARK: - url
    /// *****************************************
    /// Give the url to the file, respecting if the extension lives in a package or in the main code
    ///
    /// How to use:
    /// ```swift
    /// guard let url = sound.url else {
    ///     print("❌ Could not load sound: \(sound.name)")
    ///     return
    /// }
    var url: URL? {
        Bundle.agarCoreKit.url(forResource: name, withExtension: ext)
    }
}


extension Bundle {
    static var agarCoreKit: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle.main
#endif
    }
}

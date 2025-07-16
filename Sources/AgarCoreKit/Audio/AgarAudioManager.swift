//
//  AudioManager.swift
//  Agar_HapticSoundGenerator
//
//  Created by Michael Lekrans on 2025-07-11.
//


import AVFoundation
import Foundation

public class AudioManager {
    private var engine: AVAudioEngine?
    
    
    public init() {
        engine = AVAudioEngine()
        //        player = AVAudioPlayerNode()
        //        timePitch = AVAudioUnitTimePitch() // Controls pitch and rate
        
        //        prepareAudio()
    }
    
    private func prepareAudio() {
        //        guard let engine = engine else { return }
        //        engine.attach(player)
        //        engine.attach(timePitch)
    }
    
    func playModifiedSound(sound: AgarAudioResource) {
        print("In playModifiedSound")
        print("sound = \(sound)")
        guard let engine = engine else {
            print("⚠️ engine is nil")
            return
        }
        
        
        //        let fileNameNoExt = String(fileName.split(separator: ".").first ?? "")
        //        let ext = String(fileName.split(separator: ".").last ?? "")
        //
        print("sound.name \(sound.name)")
        print("sound.ext \(sound.ext)")
        guard let url = Bundle.module.url(forResource: sound.name, withExtension: sound.ext),
              let file = try? AVAudioFile(forReading: url) else {
            print("❌ sound '\(sound.name)' not found")
            return
        }
        
        let player: AVAudioPlayerNode = AVAudioPlayerNode()
        let timePitch =  AVAudioUnitTimePitch()
        
        engine.attach(player)
        engine.attach(timePitch)
        
        timePitch.rate = sound.rate      // Playback rate (1.0 is normal)
        print(" ")
        print("playModifiedSound")
        print("timePitch.rate \(timePitch.rate)")
        timePitch.pitch = sound.pitch    // In cents, +1000 = 1 octave up
        print("timePitch.pitch \(timePitch.pitch)")
        player.volume = sound.volume
        print("player.volume \(player.volume)")
        
        engine.connect(player, to: timePitch, format: file.processingFormat)
        engine.connect(timePitch, to: engine.mainMixerNode, format: file.processingFormat)
        
        if !engine.isRunning {
            print("engine was not runnng")
            do {
                print("before engine.start")
                try engine.start()
            } catch {
                print("Could not start AudioEngine: \(error)")
                return
            }
        }
        
        //        try? engine.start()
        
        player.scheduleFile(file, at: nil, completionHandler: nil)
        player.play()
    }
}

import AudioKit
import Combine

class Conductor: ObservableObject {
    let engine = AudioEngine()
    let drums = AppleSampler()
    
    let drumSamples: [DrumSample] =
    [
        DrumSample("HI TOM", file: "hi_tom_D2", note: 38),
        DrumSample("CRASH", file: "crash_F1", note: 29),
        DrumSample("HI HAT", file: "closed_hi_hat_F#1", note: 30),
        DrumSample("OPEN HI HAT", file: "open_hi_hat_A#1", note: 34),
        DrumSample("LO TOM", file: "mid_tom_B1", note: 35),
        DrumSample("CLAP", file: "clap_D#1", note: 27),
        DrumSample("KICK", file: "bass_drum_C1", note: 24),
        DrumSample("SNARE", file: "snare_D1", note: 26),
    ]
    
    var drumPadTouchCounts: [Int] = [] {
        willSet {
            for index in 0..<drumPadTouchCounts.count {
                if newValue[index] > drumPadTouchCounts[index] {
                    playPad(padNumber: index)
                }
            }
        }
    }
    
    init() {
        engine.output = drums
        drumPadTouchCounts = Array(repeating: 0, count: drumSamples.count)
    }
    
    func start() {
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start! \(error)")
        }
        
        // Load drum sounds
        do {
            let files = drumSamples.compactMap { $0.audioFile }
            try drums.loadAudioFiles(files)
        } catch {
            Log("Could not load audio files \(error)")
        }
    }
    
    func playPad(padNumber: Int, velocity: Float = 1.0) {
        if !engine.avEngine.isRunning {
            start()
        }
        
        drums.play(
            noteNumber: MIDINoteNumber(drumSamples[padNumber].midiNote), 
            velocity: MIDIVelocity(velocity * 127.0))
    }
}

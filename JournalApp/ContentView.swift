import SwiftUI
import SlidingTabView
import AVFoundation

struct ContentView: View {
    @State private var tabIndex = 0 // This will tell us what tab we have currently selected
    @State private var isRecording = false // Whether recording is in progress
    
    var body: some View {
        VStack {
            SlidingTabView(selection: $tabIndex, tabs: ["Challenging", "Grateful", "Beautiful"], animation: .easeInOut, activeAccentColor: .orange)
            
            Spacer() // This is so that it consumes all the space and pushes it to the top of the screen.
            
            if tabIndex == 0 {
                RecordView(tabTitle: "Challenging", isRecording: $isRecording)
            } else if tabIndex == 1 {
                RecordView(tabTitle: "Grateful", isRecording: $isRecording)
            } else if tabIndex == 2 {
                RecordView(tabTitle: "Beautiful", isRecording: $isRecording)
            }
        }
    }
}

struct RecordView: View {
    var tabTitle: String
    @Binding var isRecording: Bool // Whether recording is in progress
    
    @State private var audioRecorder: AVAudioRecorder? // Audio recorder instance
    @State private var audioURL: URL? // Recorded audio file URL
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text(tabTitle)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.heavy))
                
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                    isRecording.toggle()
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        // Store the audio URL for later use
        audioURL = getDocumentsDirectory().appendingPathComponent("recording.wav")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

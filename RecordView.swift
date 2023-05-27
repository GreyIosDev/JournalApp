//
//  RecordView.swift
//  JournalApp
//
//  Created by Grey  on 26.05.2023.
//

import SwiftUI
import AVFAudio

struct RecordView: View {
    
    var tabTitle: String = "Grateful"
    
    @State private var audioRecorder: AVAudioRecorder? // Audio recorder instance
    @State private var audioPlayer: AVAudioPlayer? // Audio player instance
    @State private var audioURLs: [URL] = [] // Recorded audio file URLs
    @State private var recordingDuration: TimeInterval = 0 // Recording duration in seconds
    @State private var timer: Timer? // Timer to update the recording duration
    @State private var isRecording = false // Whether recording is in progress
    var color: LinearGradient = LinearGradient(gradient: Gradient(colors: [.orange, .pink]), startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        
        ZStack {
            Text("Record something that was \(tabTitle) during the day")
            
            color
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Text("Record something that you found \(tabTitle) during the day")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .font(.title)
                        .multilineTextAlignment(.center)
                }
                Text(tabTitle)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.heavy))
                
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                }
                
                if !audioURLs.isEmpty {
                    Button(action: {
                        playRecordings()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                    }
                }
                
                if audioURLs.count > 0 {
                    Button(action: {
                        clearRecordings()
                    }) {
                        Text("Clear Recordings")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .onAppear {
            loadRecordings()
        }
        .onDisappear {
            stopRecording()
        }
    }
    
        
        func startRecording() {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(audioURLs.count + 1).wav")
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder?.record()
                
                isRecording = true
                startTimer()
            } catch {
                print("Failed to start recording: \(error.localizedDescription)")
            }
        }
        
        func stopRecording() {
            audioRecorder?.stop()
            audioRecorder = nil
            
            isRecording = false
            resetTimer()
            
            // Store the audio URL for later use
            if let lastRecordingURL = audioURLs.last {
                if FileManager.default.fileExists(atPath: lastRecordingURL.path) {
                    audioURLs.append(lastRecordingURL)
                }
            }
        }
        
        func playRecordings() {
            audioPlayer?.stop()
            
            if let lastRecordingURL = audioURLs.last {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: lastRecordingURL)
                    audioPlayer?.play()
                } catch {
                    print("Failed to play recording: \(error.localizedDescription)")
                }
            }
        }
        
        func clearRecordings() {
            let fileManager = FileManager.default
            do {
                for url in audioURLs {
                    try fileManager.removeItem(at: url)
                }
                
                audioURLs.removeAll()
            } catch {
                print("Failed to delete recordings: \(error.localizedDescription)")
            }
        }
        
        func loadRecordings() {
            let fileManager = FileManager.default
            do {
                let documentDirectory = getDocumentsDirectory()
                let directoryContents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
                
                audioURLs = directoryContents.filter { $0.pathExtension == "wav" }
            } catch {
                print("Failed to load recordings: \(error.localizedDescription)")
            }
        }
        
        func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                recordingDuration += 1
                
                if recordingDuration >= 240 {
                    stopRecording()
                }
            }
        }
        
        func resetTimer() {
            timer?.invalidate()
            timer = nil
            recordingDuration = 0
        }
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(tabTitle:"Challenging", color: LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom))
    }
}

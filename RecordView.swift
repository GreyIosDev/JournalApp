import SwiftUI
import AVFAudio
import Firebase
import FirebaseFirestore
import FirebaseStorage


struct AudioRecording {
    let fileURL: URL
    let createdAt: Date
}

struct RecordView: View {
    var tabTitle: String = "Grateful"
    
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var recordings: [AudioRecording] = []
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isRecording = false
    var color: LinearGradient = LinearGradient(gradient: Gradient(colors: [.orange, .pink]), startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        ZStack {
            Text("Record something that was \(tabTitle) during the day")
            color.ignoresSafeArea()
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
                
                if !recordings.isEmpty {
                    List {
                        ForEach(recordings, id: \.fileURL) { recording in
                            HStack {
                                Text("\(recording.createdAt)")
                                Spacer()
                                Button("Play") {
                                    playRecording(url: recording.fileURL)
                                }
                            }
                        }
                    }
                }
                
                if recordings.count > 0 {
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
        // Request for permission
        requestMicrophonePermission { granted in
            if granted {
                // If permission is granted, start the recording
                let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(recordings.count + 1).wav")
            
                let settings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatLinearPCM,
                    AVSampleRateKey: 44100.0,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
            
                do {
                    self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                    self.audioRecorder?.record()
                
                    self.isRecording = true
                    self.startTimer()
                } catch {
                    print("Failed to start recording: \(error.localizedDescription)")
                }
            } else {
                // If not granted, show a message to the user
                print("Microphone access denied")
            }
        }
    }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        resetTimer()
        
        if let url = audioRecorder?.url {
            let newRecording = AudioRecording(fileURL: url, createdAt: Date())
            recordings.append(newRecording)
            uploadRecordingToFirebase(recording: newRecording)
        }
    }
    
    func playRecording(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
        }
    }
    
    func clearRecordings() {
        let fileManager = FileManager.default
        do {
            for recording in recordings {
                try fileManager.removeItem(at: recording.fileURL)
            }
            
            recordings.removeAll()
        } catch {
            print("Failed to delete recordings: \(error.localizedDescription)")
        }
    }
    
    func loadRecordings() {
        let fileManager = FileManager.default
        do {
            let documentDirectory = getDocumentsDirectory()
            let directoryContents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            
            recordings = directoryContents.filter { $0.pathExtension == "wav" }.map { AudioRecording(fileURL: $0, createdAt: Date()) }
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
    
    func uploadRecordingToFirebase(recording: AudioRecording) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let recordingRef = storageRef.child("recordings/\(UUID().uuidString).wav")
        
        recordingRef.putFile(from: recording.fileURL, metadata: nil) { metadata, error in
            guard let _ = metadata else {
                print("Failed to upload file to Firebase: \(error?.localizedDescription ?? "")")
                return
            }

            recordingRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Failed to get download URL: \(error?.localizedDescription ?? "")")
                    return
                }

                print("Uploaded file to \(downloadURL)")
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(tabTitle:"Challenging", color: LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom))
    }
}

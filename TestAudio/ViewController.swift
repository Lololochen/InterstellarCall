//
//  ViewController.swift
//  TestAudio
//
//  Created by yy on 2017/8/29.
//  Copyright © 2017年 yy. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var timer: Timer!
    
    override func viewDidLoad() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        print("Record failed")
                    }
                }
            }
        } catch {
            print("Record failed 2")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    @IBAction func Record(_ sender: UIButton) {
        
        // stops recording if recording is ongoing
        if timer != nil {
            if timer.isValid {
                self.timer.invalidate()
                return
            }
        }
        
        // starts recording if no recording is going on
        timer = Timer(timeInterval: 1, repeats: true, block: { (_) in
            self.recordAndPrint()
        })
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        timer.fire()
        
        // bug在这里，参考
        // https://stackoverflow.com/questions/24369602/using-an-nstimer-in-swift
        // 以下是一个更简洁的实现方式
        
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {{ (_) in
//            // ...
//            }})
//
    }
    
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            print("Audio recorded")
    
        } catch {
            print("Failed to initialize recorder")
        }
    }
        
    func recordAndPrint() {
        if audioRecorder == nil {
            startRecording()
        } else if audioRecorder.isRecording {
            audioRecorder.stop()
            startRecording()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            audioRecorder.stop()
            print("Record unsuccessful")
        }
    }

}


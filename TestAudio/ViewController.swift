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
    var audioPlayer: AVQueuePlayer!
    var dpLink: CADisplayLink!
    
    //    var timer: Timer!  //NSTimer
    
    //    // CADisplayLink 官方文档示例
    //    func createDisplayLink() {
    //        let displaylink = CADisplayLink(target: self,
    //                                        selector: #selector(step))
    //
    //        displaylink.add(to: .current,
    //                        forMode: .defaultRunLoopMode)
    //    }
    //
    //    @objc func step(displaylink: CADisplayLink) {
    //        print(displaylink.timestamp)
    //    }
    
    
    //    // oc CADisplaylink
    //    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(testDisplayLink)];
    //    link.paused = NO;
    //    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
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
    
    @objc func update(){
        print("recording started.")
        recordAndPrint()
    }
    
    func startDpLink(){
        dpLink = CADisplayLink(target: self, selector: #selector(update))
        dpLink.preferredFramesPerSecond = 60
        dpLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        dpLink.isPaused = false
    }
    
    func stopDpLink(){
        dpLink.invalidate()
    }
    
    
    @IBAction func Record(_ sender: UIButton) {
        
        if dpLink != nil {
            stopDpLink()
        }
        startDpLink()
        
        
        //        // stops recording if recording is ongoing
        //        if timer != nil {
        //            if timer.isValid {
        //                self.timer.invalidate()
        //                return
        //            }
        //        }
        //
        //        // starts recording if no recording is going on
        //        timer = Timer(timeInterval: 1, repeats: true, block: { (_) in
        //            self.recordAndPrint()
        //        })
        //        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        //        timer.fire()
        
    }
    
    
    func startRecording() {
        let fileName = Date()
        let fileDirectory = getDocumentsDirectory().appendingPathComponent(String(describing: fileName) + ".m4a")
        // m4a is a type of mp4, more efficient than mp3
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileDirectory, settings: settings)
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
    
    @IBAction func play(_ sender: UIButton) {
        var audioItems: [AVPlayerItem] = []
        
        // Get the document directory url
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            // print(directoryContents)
            for url in directoryContents {
                audioItems.append(AVPlayerItem(url: url))
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        audioPlayer = AVQueuePlayer(items: audioItems)
        audioPlayer.play()
    }
    
}


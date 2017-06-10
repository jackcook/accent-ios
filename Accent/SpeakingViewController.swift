//
//  SpeakingViewController.swift
//  Accent
//
//  Created by Jack Cook on 6/10/17.
//  Copyright © 2017 Jack Cook. All rights reserved.
//

import Accelerate
import Speech
import UIKit

class SpeakingViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var sentenceLabel: UILabel!
    @IBOutlet weak var microphoneButton: MicrophoneButton!
    
    fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr_FR"))!
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    fileprivate let audioEngine = AVAudioEngine()
    
    fileprivate var averagePower: Float = 0
    
    // 0 < volume < 100
    fileprivate var volume: Int {
        return min(max(Int(averagePower + 75), 0), 100)
    }
    
    fileprivate var animationTimer: Timer?
    fileprivate var currentExercise: SpeakingExercise?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentExercise = pickNextExercise()
        sentenceLabel.text = currentExercise?.text
        
        speechRecognizer.delegate = self
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: figure out permissions/authorization UI later
        if AVAudioSession.sharedInstance().recordPermission() == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { response in
                if SFSpeechRecognizer.authorizationStatus() == .notDetermined {
                    SFSpeechRecognizer.requestAuthorization { status in
                        
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    // MARK: IBActions
    
    @IBAction func microphoneButtonPressed(sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // MARK: Private Methods
    
    fileprivate func pickNextExercise() -> SpeakingExercise? {
        let exercise = SpeakingExercise(text: "Je suis", mistakes: [
            "Je suis une blague": "You mispronounced baguette"
        ])
        
        return exercise
    }
    
    fileprivate func startRecording() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            // TODO: catch errors
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode, let recognitionRequest = recognitionRequest else {
            // TODO: catch errors
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .dictation
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                print(result.bestTranscription.formattedString)
                isFinal = result.bestTranscription.formattedString == self.currentExercise?.text || result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
            
            buffer.frameLength = 1024
            let inNumberFrames = UInt(buffer.frameLength)
            
            guard let samples = buffer.floatChannelData?[0] else {
                return
            }
            
            var averageValue: Float = 0
            vDSP_meamgv(samples, 1, &averageValue, inNumberFrames)
            
            let lowpassLevel: Float = 0.1
            self.averagePower = (lowpassLevel * (averageValue == 0 ? -100 : 20 * log10f(averageValue))) + ((1 - lowpassLevel) * self.averagePower)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            // TODO: catch errors
        }
        
        animationTimer = Timer.scheduledTimer(timeInterval: microphoneVolumeAnimationDuration, target: self, selector: #selector(updateIndicatorView), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopRecording() {
        animationTimer?.invalidate()
        animationTimer = nil
        
        microphoneButton.dismissIndicator()
        
        audioEngine.stop()
        audioEngine.inputNode?.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        currentExercise = pickNextExercise()
        sentenceLabel.text = currentExercise?.text
    }
    
    @objc fileprivate func updateIndicatorView() {
        microphoneButton.updateVolume(volume)
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // TODO: deal with UI for this later
    }
}

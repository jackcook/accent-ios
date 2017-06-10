//
//  ListeningViewController.swift
//  Accent
//
//  Created by Jack Cook on 6/10/17.
//  Copyright © 2017 Jack Cook. All rights reserved.
//

import AVFoundation
import UIKit

class ListeningViewController: UIViewController, AVAudioPlayerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answerTextFieldBottomConstraint: NSLayoutConstraint!
    
    fileprivate let exercise = ListeningExercise(id: 0, name: "test", sentences: ["Je suis une baguette"])
    fileprivate var player = AVAudioPlayer()
    
    fileprivate var playing = false
    fileprivate var started = false
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = playButton.frame.width / 2
        
        answerTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        answerTextField.resignFirstResponder()
    }
    
    // MARK: Private Methods
    
    fileprivate func updateBottomLayoutConstraint(with notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        if convertedKeyboardEndFrame.origin.y >= view.frame.size.height {
            // 32 = the default value for this constraint in the storyboard
            answerTextFieldBottomConstraint.constant = 32
        } else {
            answerTextFieldBottomConstraint.constant = view.frame.size.height - convertedKeyboardEndFrame.origin.y + 32
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: IBActions
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if playing {
            playButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            player.pause()
            
            playing = false
        } else {
            playButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            
            if !started {
                let url = exercise.audioURL(for: 0)
                
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                
                let task = session.dataTask(with: url) { (data, response, error) in
                    guard let data = data else {
                        return
                    }
                    
                    do {
                        self.player = try AVAudioPlayer(data: data)
                        self.player.delegate = self
                        self.player.play()
                    } catch {
                        
                    }
                }
                
                task.resume()
            } else {
                player.play()
            }
            
            playing = true
            started = true
        }
    }
    
    // MARK: Notifications
    
    @objc fileprivate func keyboardWillShow(notification: Notification) {
        updateBottomLayoutConstraint(with: notification)
    }
    
    @objc fileprivate func keyboardWillHide(notification: Notification) {
        updateBottomLayoutConstraint(with: notification)
    }
    
    // MARK: AVAudioPlayerDelegate Methods
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        
        playing = false
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.25) { 
            self.playButton.backgroundColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
        }
        
        UIView.transition(with: playButton, duration: 0.25, options: .transitionCrossDissolve, animations: { 
            self.playButton.setImage(#imageLiteral(resourceName: "Check"), for: .normal)
        }, completion: nil)
        
        playing = false
        started = false
        
        return true
    }
}

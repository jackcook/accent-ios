//
//  ListeningViewController.swift
//  Accent
//
//  Created by Jack Cook on 6/10/17.
//  Copyright © 2017 Jack Cook. All rights reserved.
//

import AVFoundation
import UIKit

class ListeningViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var answerTextViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = playButton.frame.width / 2
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
        super.touchesBegan(touches, with: event)
        
        answerTextView.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func playButtonPressed(sender: UIButton) {
        let string = "Je suis une baguette"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
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
            answerTextViewBottomConstraint.constant = 32
        } else {
            answerTextViewBottomConstraint.constant = view.frame.size.height - convertedKeyboardEndFrame.origin.y + 32
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: Notifications
    
    @objc fileprivate func keyboardWillShow(notification: Notification) {
        updateBottomLayoutConstraint(with: notification)
    }
    
    @objc fileprivate func keyboardWillHide(notification: Notification) {
        updateBottomLayoutConstraint(with: notification)
    }
}

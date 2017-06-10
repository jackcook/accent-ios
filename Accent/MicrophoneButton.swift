//
//  MicrophoneButton.swift
//  Accent
//
//  Created by Jack Cook on 6/10/17.
//  Copyright © 2017 Jack Cook. All rights reserved.
//

import UIKit

let microphoneVolumeAnimationDuration = 0.1

class MicrophoneButton: UIButton {
    
    // MARK: Properties
    
    fileprivate var indicatorView: UIView!
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)
        clipsToBounds = true
        layer.cornerRadius = frame.size.width / 2
        tintColor = .white
        
        setImage(#imageLiteral(resourceName: "Microphone"), for: .normal)
        
        indicatorView = UIView()
        indicatorView.backgroundColor = UIColor(red: 0, green: 85/255, blue: 164/255, alpha: 1)
        indicatorView.frame = CGRect(x: 0, y: frame.size.height, width: frame.size.width, height: 0)
        indicatorView.isUserInteractionEnabled = false
        
        if let imageView = imageView {
            insertSubview(indicatorView, belowSubview: imageView)
        } else {
            addSubview(indicatorView)
        }
    }
    
    // MARK: Public Methods
    
    func dismissIndicator() {
        UIView.animate(withDuration: microphoneVolumeAnimationDuration) {
            self.indicatorView.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 0)
        }
    }
    
    func updateVolume(_ volume: Int) {
        let indicatorHeight = frame.size.height * (CGFloat(volume) / 65)
        
        UIView.animate(withDuration: microphoneVolumeAnimationDuration) {
            self.indicatorView.frame = CGRect(x: 0, y: self.frame.size.height - indicatorHeight, width: self.frame.size.width, height: indicatorHeight)
        }
    }
}

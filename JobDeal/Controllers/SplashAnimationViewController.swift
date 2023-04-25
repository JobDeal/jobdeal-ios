//
//  SplashAnimationViewController.swift
//  JobDeal
//
//  Created by Darko Batur on 27/01/2021.
//  Copyright © 2021 Priba. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class SplashAnimationViewController: UIViewController {
    @IBOutlet weak var animationView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         playVideo()
     }
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "videoSplash", ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.showsPlaybackControls = false
        playerController.videoGravity = .resizeAspect
        playerController.view.backgroundColor = UIColor.white
        playerController.player = player
        self.addToChild(vc: playerController, view: self.animationView)
        player.play()
    }
}

//
//  ViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation // 3

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		
		requestPermissionAndShowCamera() // 2
		
	}

	private func requestPermissionAndShowCamera() { // 1
		let status = AVCaptureDevice.authorizationStatus(for: .video) // 4

		switch status { // 5
		case .notDetermined:
			// First time user - they haven't seen the dialog to give permission
			requestPermission() // 7
		case .restricted:
			// Parental controls disabled the camera // 8
			fatalError("Video is disabled fro the user (parental controls)") //10
		case .denied: // 9
			// User did not give us access (maybe it was a accident)
			fatalError("Tell the use they need to enable Privacy for Video") // 11
		case .authorized:
			// we asked for permission (2nd time they've used the app)
			showCamera() // 9

		@unknown default:
			fatalError("A new status was added that we need to handle") // 12
		}
	}

	private func requestPermission() { // 6
		AVCaptureDevice.requestAccess(for: .video) { (granted) in // 13
			guard granted else {
				fatalError("Tell user they need to enable Privacy for Video")
			}
			DispatchQueue.main.async { [weak self] in
				self?.showCamera()
			}
		}
	}

	private func showCamera() {
		performSegue(withIdentifier: "ShowCamera", sender: self)
	}
}

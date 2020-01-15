//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation // 17

class CameraViewController: UIViewController {

	lazy private var captureSession = AVCaptureSession() //21
	lazy private var fileOutput = AVCaptureMovieFileOutput() // 22

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!


	override func viewDidLoad() {
		super.viewDidLoad()

		// Resize camera preview to fill the entire screen
		cameraView.videoPlayerView.videoGravity = .resizeAspectFill

		setUpCamera() // 15

		// TODO: Add tap gesture to replay videos
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		captureSession.startRunning()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		captureSession.stopRunning()
	}

    @IBAction func recordButtonPressed(_ sender: Any) {
		toogleRecording() // 26
	}

	// Methods

	func updateViews() { // 30
		recordButton.isSelected = fileOutput.isRecording // 31
	}

	func toogleRecording() { // 26
		if fileOutput.isRecording {
			// stop
			fileOutput.stopRecording() // 34
		} else {
			// start
			fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self) // 27
		}
	}


	func setUpCamera() { // 14
		let camera = bestCamera() // 17
		captureSession.beginConfiguration()
		// make changes to the devices connected
		// Video input
		guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
			fatalError("Cannot create camera input") // 18
		}
		guard captureSession.canAddInput(cameraInput) else { // 20
			fatalError("Cannot add camera input to session")
		}
		captureSession.addInput(cameraInput) // 21
		if captureSession.canSetSessionPreset(.hd1920x1080) {
			captureSession.canSetSessionPreset(.hd1920x1080)
		}
		// TODO: Audio input
		// TODO: Video output (movie)
		guard captureSession.canAddOutput(fileOutput) else { // 23
			fatalError("Can't setup the file output for the movie")
		}
		captureSession.addOutput(fileOutput) //24

		captureSession.commitConfiguration() // 19
		cameraView.session = captureSession
	}


	/// WideAngle Lens is on every iphone that has shipped through 2019
	private func bestCamera() -> AVCaptureDevice { // 16
		if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
			return device
		}
		// Fallback camera
		if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			return device
		}
		fatalError("No cameras on the device. Or you are running on the Simulator (not supported)")
	}


	/// Creates a new file URL in the documents directory
	private func newRecordingURL() -> URL {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]

		let name = formatter.string(from: Date())
		let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
		return fileURL
	}
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate { // 28
	func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
		if let error = error { // 29
			print("Error saving video: \(error)")
		}
		print("Video: \(outputFileURL.path)") // 33
		updateViews() // 33
	}

	func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
		updateViews() //32
	}
}


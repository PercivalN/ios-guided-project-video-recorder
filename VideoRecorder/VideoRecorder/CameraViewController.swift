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
	var player: AVPlayer? // 38

	@IBOutlet var recordButton: UIButton!
	@IBOutlet var cameraView: CameraPreviewView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Resize camera preview to fill the entire screen
		cameraView.videoPlayerView.videoGravity = .resizeAspectFill

		setUpCamera() // 15

		// TODO: Add tap gesture to replay videos
		let tapGesture = UITapGestureRecognizer(target: self, action: // 45
			#selector(handleTapGesture(tapGesture:)))
		view.addGestureRecognizer(tapGesture)
	}

	@objc func handleTapGesture(tapGesture: UITapGestureRecognizer) { //46
		if tapGesture.state == .ended {
			playRecording()
		}
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

	func playRecording() { // 44
		if let player = player {
			player.seek(to: CMTime.zero)
			player.play()
		}
	}

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

		// Audio input

		let microphone = bestAudio()
		guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
			fatalError("Can't create input from microphone")
		}
		guard captureSession.canAddInput(audioInput) else {
			fatalError("Can't add audio input")
		}
		captureSession.addInput(audioInput)


		// Video output (movie)
		guard captureSession.canAddOutput(fileOutput) else { // 23
			fatalError("Can't setup the file output for the movie")
		}
		captureSession.addOutput(fileOutput) //24

		captureSession.commitConfiguration() // 19
		cameraView.session = captureSession
	}

	private func bestAudio() -> AVCaptureDevice {
		if let device = AVCaptureDevice.default(for: .audio) {
			return device
		}
		fatalError("No audio")
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

	func playMovie(url: URL) { // 37

		player = AVPlayer(url: url) //39
		let playerLayer = AVPlayerLayer(player: player) // 40
		var topRect = view.bounds
		topRect.size.height = topRect.height / 4
		topRect.size.width = topRect.width / 4
		topRect.origin.y = view.layoutMargins.top

		//playerLayer.frame = view.bounds // 43

		playerLayer.frame = topRect // 44
		view.layer.addSublayer(playerLayer) // 41
		player?.play() // 42
	}
}


extension CameraViewController: AVCaptureFileOutputRecordingDelegate { // 28
	func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
		if let error = error { // 29
			print("Error saving video: \(error)")
		}
		print("Video: \(outputFileURL.path)") // 33
		updateViews() // 33

		playMovie(url: outputFileURL) // 36
	}

	func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
		updateViews() //32
	}
}


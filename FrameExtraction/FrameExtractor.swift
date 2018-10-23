//
//  FrameExtractor.swift
//  FrameExtraction
//
//  Created by Sheila Gonzalez on 17/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

import UIKit            // Remove line?
import AVFoundation     // To access camera

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage,cropped:[UIImage])
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: FrameExtractorDelegate?
    
    // The session coordinates the flow of data from the input to the output
    private let captureSession = AVCaptureSession()
    
    // Create a serial queue that will handle the work related to the session
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    // Declare a variable to track if the permission is granted
    private var permissionGranted = false
    
    // Which camera (front/back)
    private let position = AVCaptureDevice.Position.back
    
    // Image quality
    private let quality = AVCaptureSession.Preset.medium
    
    let context = CIContext()
    
    // Constructor
    override init(){
        super.init()
        
        checkPermission()
        // Add async configuration on the session queue
        sessionQueue.async {
            [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    private func checkPermission(){
        // Check for permission
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        {
        case .authorized:
            // The user has explicitly granted permission for media capture
            permissionGranted = true
            break
        case .notDetermined:
            requestPermission()
            break
        default:
            // The user has denied permission
            permissionGranted = false
            break
        }
    }
    
    private func requestPermission(){
        sessionQueue.suspend()
        // The user has not yet granted or denied permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video){
            [unowned self] granted in       // did not really understand this line
            self.permissionGranted = granted
            // Suspend session queue and resume once we get a result from the user
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession(){
        guard permissionGranted else { return }
        captureSession.sessionPreset = quality
        
        // Find a valid device
        guard let captureDevice = selectCaptureDevice() else { return }
        
        // Create an AVCaptureDeviceInput
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        // Check if the capture device input can be added to the session, and add it
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        
        // To intercept each frame, create an instance of AVCaptureVideoDataOutput
        let videoOutput = AVCaptureVideoDataOutput()
        
        // Set FrameExtractor as delegate
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice?{
        // Select only the targeted capture device.
        // For every device in the array of devices, check:
        //      - If it's a video recording device
        //      - If it is the front camera
        return AVCaptureDevice.devices().filter{
            ($0 as AnyObject).hasMediaType(AVMediaType.video) &&
                ($0 as AnyObject).position == position
        }.first as? AVCaptureDevice
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage?{
        // 1. Transform the sample buffer to a CVImageBuffer
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        // 2. Create a CIImage from the image buffer
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        // 3. Create a CIContext and create a CGImage from this context
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        // 4. Create and return the UIImage
        return UIImage(cgImage: cgImage)
    }
    
    // This method is called every time a new frame is available
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let uiImage = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        //uiImage = OpenCVWrapper.testProcess(uiImage)      // Test - convert images to grayscale
       let  arrayOfImages = OpenCVWrapper.getProcessedImage(uiImage)    // Good one, object detection
        DispatchQueue.main.async {
            [unowned self] in
            
            self.delegate?.captured(image: uiImage, cropped: arrayOfImages)

            
        }
    }
}

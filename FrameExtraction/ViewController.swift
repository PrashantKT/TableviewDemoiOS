//
//  ViewController.swift
//  FrameExtraction
//
//  Created by Sheila Gonzalez on 17/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

import UIKit
import AbbyyRtrSDK


class ViewController: UIViewController, FrameExtractorDelegate {
   
    
    
    var frameExtractor: FrameExtractor!
    
    private var textCaptureService: RTRTextCaptureService?
    private var selectedRecognitionLanguages = Set(["English"])

    private var arrayCroppedImages:[UIImage] = []

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        
    
        
    }
    
    func captured(image: UIImage, cropped: [UIImage]) {
        DispatchQueue.global().async {
            if let lastObject = cropped.last {
                self.handleWithOCR(image: lastObject)
                self.arrayCroppedImages.insert(lastObject, at: 0)
            }
       //     for imageCropped in cropped {
          //  }
            DispatchQueue.main.async {
                [unowned self] in
                self.imageView.image = image
                
            }
        }
    }

   
   
    
    private func handleWithOCR (image:UIImage) {
       let text =  OCRReader.sharedInstance.handleWithOCR(image:image)
        
        for textBlock in text ?? [] {
            for textLine in textBlock.textLines {
                
                // if textLine.text.lowercased().contains("heada") || textLine.text.lowercased().contains("arthr")   {
                DispatchQueue.main.async {
                    (self.view.viewWithTag(50) as? UITextView)?.text =  ((self.view.viewWithTag(50) as? UITextView)?.text ?? "") + textLine.text
                    
                }
                //     break
                //    }
                
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cropper = segue.destination as? CroppedImageVC {
            cropper.arrayToShow = self.arrayCroppedImages
        }
    }
   
}



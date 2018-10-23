//
//  OCRReader.swift
//  FrameExtraction
//
//  Created by Prashant on 23/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

import Foundation
import UIKit
import AbbyyRtrSDK

final class OCRReader:NSObject {
    
    static let sharedInstance = OCRReader()
    
    var engine:RTREngine?
    var coreAPI:RTRCoreAPI?
    var isTrackingInProgress = false
    
    
    private override init () {
        super.init()
        setupOCR()
    }
    
    
    
    private func setupOCR () {
        
        let licensePath = (Bundle.main.bundlePath as NSString).appendingPathComponent("SRAT01000006560723328094.ABBYY.License")
        self.engine = RTREngine.sharedEngine(withLicense: NSData(contentsOfFile: licensePath) as Data!)
        assert(self.engine != nil)
        
        guard engine != nil else {
            assertionFailure()
            return
        }
        
        self.coreAPI = self.engine?.createCoreAPI()
        self.coreAPI?.textRecognitionSettings.setRecognitionLanguages(["English"])
        
        
        
    }
    
    
     func handleWithOCR (image:UIImage) -> [RTRTextBlock]? {
        guard self.isTrackingInProgress == false  else {
            return nil
        }
        self.isTrackingInProgress = true
        
        do {
            
            let text =   try self.coreAPI?.recognizeText(on: image, onProgress: { (progress, callback) -> Bool in
                return true
            }, onTextOrientationDetected: { (orienation) in
                print(orienation)
                
            })
            
            print(text?.compactMap{$0.textLines.compactMap{$0.text}})
            self.isTrackingInProgress = false
          
            return text
            
            
        }catch {
            self.isTrackingInProgress = false
            
            print("error",error)
            return nil
        }
        
    }

}

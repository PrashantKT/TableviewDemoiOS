//
//  CroppedImageVC.swift
//  FrameExtraction
//
//  Created by Prashant on 23/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

import UIKit

class CroppedImageVC: UIViewController,UITableViewDelegate {

    //MARK:- Outlets
    
    @IBOutlet weak var tableview: UITableView!
    
    //MARK:- Var
    
    var arrayToShow = [UIImage]()
    
    //--------------------------------------------------------------------------------
    
    //MARK:- Memory Managment Methods
    
    //--------------------------------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    
    //--------------------------------------------------------------------------------
    
    //MARK:- ViewLifeCycle Methods
    
    //--------------------------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Press to detect image text"
    }
    
    //--------------------------------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //--------------------------------------------------------------------------------
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    


}


extension CroppedImageVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cel = tableView.dequeueReusableCell(withIdentifier: "testImageViewer", for: indexPath)
        (cel.contentView.viewWithTag(50) as? UIImageView)?.image = self.arrayToShow[indexPath.row]
        return cel
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var image = self.arrayToShow[indexPath.row]
      //  image = OpenCVWrapper.testProcess(image)
        let detectedTextBlock = OCRReader.sharedInstance.handleWithOCR(image: image)
        
        var str = ""
        for textLine in detectedTextBlock ?? [] {
            for text in textLine.textLines {
                str += text.text
            }
        }
        
        let alertController = UIAlertController(title: "Detected text", message: str, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

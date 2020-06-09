//
//  ViewController.swift
//  Object Detection
//
//  Created by Evergreen Technologies on 6/7/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userPickedImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if isCameraAvailable()
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            userPickedImageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else { fatalError(" Failed to convert image to CIImage")}
            detect(image: ciImage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }
    
    func detect(image : CIImage)
    {
        //submit the image tp inception v3 model and perform inference
        guard let model = try? VNCoreMLModel(for : Inceptionv3().model) else { fatalError(" error loading ml model ") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Failed to get nodel results") }
            
            if  let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do
        {
            try handler.perform([request])
        }
        catch{
            print("There was error while running inference. Message : \(error.localizedDescription)")
        }
        
    
        
    }
    


    @IBAction func cameraClicked(_ sender: UIBarButtonItem) {
        
        if isCameraAvailable()
        {
            present(imagePicker, animated: true, completion: nil)
        }
        
        
        
    }
    
    func isCameraAvailable() -> Bool {
        
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            return true
        }
        else
        {
            let alertController = UIAlertController.init(title:nil, message: "Device has no camera", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "alright", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        
        
    }
    
    
}


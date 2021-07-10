//
//  ViewController.swift
//  DogCatClassifier
//
//  Created by Shubham Mishra on 17/04/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let userClickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("Could not set user clicked image")
        }
        imageView.image = userClickedImage
        
        guard let ciImage = CIImage(image: userClickedImage) else {
            fatalError("Could not convert to ciimage")
        }
        detect(ciImage: ciImage)
    }
    
    func detect(ciImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: DogCatClassifier().model) else {
            fatalError("Could not load model")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
            if let result = results.first {
                if result.confidence >= 0.8 {
                    self.navigationItem.title = result.identifier
                } else {
                    self.navigationItem.title = "Couldn't classify☹️!!"
                }
            } else {
                self.navigationItem.title = "Couldn't classify☹️!!"
            }
        }
        
        let handler =  VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        imageView.image = .none
        navigationItem.title = "Dog Cat Classifer"
    }
}


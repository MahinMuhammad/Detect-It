//
//  ViewController.swift
//  Sea Foody
//
//  Created by Md. Mahinur Rahman on 12/22/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: Inceptionv3.urlOfModelInThisBundle))
        else{fatalError("Can not load ML model!!!")}
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results else {fatalError("Model failed to process image!!!")}
            
            if let firstResult = results.first{
                
                print(firstResult)
                
                let description = firstResult.description
                let contents = description.components(separatedBy: "\"")
                let name = contents[1]
                let percentage = String(Int(Double(firstResult.confidence) * 100))
                
                self.navigationItem.title = "\(percentage)% \(name.uppercased())"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print("Failed to perform request!!!")
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = image
            
            guard let ciimage = CIImage(image: image) else{fatalError("Can not convert UIImage to CIImage!!!")}
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true)
    }
}

//MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate{
    
}

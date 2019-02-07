//
//  ViewController.swift
//  FoodShazam
//
//  Created by Huy Phan on Feb 5, 19.
//  Copyright © 2019 Huy Phan. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
	
	@IBOutlet weak var myImageView: UIImageView!
	@IBOutlet weak var myLabel: UILabel!
	
	// MARK: - View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		let myImage = UIImage(named: "testImage")
		myImageView.image = myImage
		
		guard let ciImage = CIImage(image: myImage!) else {
			fatalError("couldn't convert UIImage to CIImage")
		}
		detectScene(image: ciImage)
	}
}

extension ViewController {
	@IBAction func buttonTap(_ sender: Any) {
		let pickerController = UIImagePickerController()
		pickerController.delegate = self
		pickerController.sourceType = .savedPhotosAlbum
		present(pickerController, animated: true)
	}
	
	func detectScene(image: CIImage) {
		myLabel.text = "Waiting for image"
		
		guard let myModel = try? VNCoreMLModel(for: iosModel().model) else {
			fatalError("Error loading CoreML model")
		}
		
		let request = VNCoreMLRequest(model: myModel) { [weak self] request, error in
			guard let dishResult = request.results as? [VNClassificationObservation],
				let topResult = dishResult.first else {
					fatalError("Error loading the results from CoreML model")
			}
			
			DispatchQueue.main.async { [weak self] in
				self?.myLabel.text = "\(topResult.identifier)"
				print("\(topResult.identifier)")
			}
		}
		
		let handler = VNImageRequestHandler(ciImage: image)
		DispatchQueue.global(qos: .userInteractive).async {
			do {
				try handler.perform([request])
			} catch {
				print(error)
			}
		}
	
	}
}

extension ViewController: UINavigationControllerDelegate {
}


// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			myImageView.image = pickedImage
			guard let ciImage = CIImage(image: pickedImage) else {
				fatalError("couldn't convert UIImage to CIImage")
			}
			detectScene(image: ciImage)
		}

		dismiss(animated: true, completion: nil)
	}
}

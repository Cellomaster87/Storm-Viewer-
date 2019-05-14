//
//  DetailViewController.swift
//  Storm Viewer
//
//  Created by Michele Galvagno on 18/02/2019.
//  Copyright © 2019 Michele Galvagno. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        title = selectedImage
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        let renderedImage = renderTextOnImage()
        if let image = renderedImage?.jpegData(compressionQuality: 0.8) {
            let vc = UIActivityViewController(activityItems: [image, selectedImage!], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem // this is for iPad
            present(vc, animated: true)
        } else {
            print("No image found")
        }
    }
    
    func renderTextOnImage() -> UIImage? {
        guard let image = imageView.image else { return nil }
        
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let renderedImage = renderer.image { ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48),
                .foregroundColor: UIColor.white.cgColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let string = "From Storm Viewer!"
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 300, height: 150), options: .usesLineFragmentOrigin, context: nil)
        }
        
        return renderedImage
    }
}

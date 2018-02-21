//
//  ViewController.swift
//  Filter
//
//  Created by Juan Jesus Cueto Yabar on 19/02/18.
//  Copyright © 2018 Juan Jesus Cueto Yabar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Images
    var filteredImage: UIImage?
    var originalImage: UIImage?
    var imageProcessor: ImageProcessor?
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var filterImage: UIImageView!
    
    //Menu
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    //Buttons
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    
    //Secondary Buttons
    @IBOutlet var brightButton: UIButton!
    @IBOutlet var warmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Set Images
        filterImage.alpha = 0
        originalImage = imageView.image
        filterImage.image = originalImage
        
        //Enable view Interactions
        imageView.isUserInteractionEnabled = true
        filterImage.isUserInteractionEnabled = true
        
        //Initialize image object
        imageProcessor = ImageProcessor(image: imageView.image!)
        imageProcessor!.getAverages()
        
        //Disable buttons
        compareButton.isEnabled = false
        editButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
// Handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch: UITouch = touches.first!
        if touch.view == self.imageView {
            if filteredImage != nil {
                UIView.animate(withDuration: 0.5, animations: {
                    self.imageView.image = self.originalImage
                })
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch: UITouch = touches.first!
        if touch.view == self.imageView {
            if filteredImage != nil {
                UIView.animate(withDuration: 0.5, animations: {
                    self.imageView.image = self.filteredImage
                })
            }
        }
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        if sender.isSelected == false {
            showSecondaryMenu()
            sender.isSelected = true
        } else {
            hideSecondaryMenu()
            sender.isSelected = false
        }
    }
    //Filter Actions
    @IBAction func onBrightFilter(_ sender: UIButton) {
        filteredImage = imageProcessor?.processImage(filter: "brightness adjust", modifier: 0.40)
        imageView.image = filteredImage
        disableButtons(sender: sender)
    }
    
    @IBAction func onWarmFilter(_ sender: UIButton) {
        filteredImage = imageProcessor?.processImage(filter: "warm adjust", modifier: 2)
        imageView.image = filteredImage
        disableButtons(sender: sender)
    }
    
    @IBAction func onNewPhoto(_ sender: UIButton) {
        //Alert Controller
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
            filterImage.image = image
            filteredImage = nil
            originalImage = imageView.image
            imageProcessor?.setImage(image: originalImage!)
            
            //Restore buttons properties
            if filterImage.alpha == 1.0 {
                onCompare(compareButton)
            }
            compareButton.isEnabled = false
            restoreButtons()
            
            //Hide Secondary Menu if is visible
            onFilter(filterButton)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Compare Action
    @IBAction func onCompare(_ sender: UIButton) {
        if self.filterImage.alpha == 0 {
            UIView.animate(withDuration: 0.4, animations: {
                self.filterImage.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.filterImage.alpha = 0
            })
        }
    }
    
    //This function set all filter's enable property to true
    func restoreButtons() {
        brightButton.isEnabled = true
        warmButton.isEnabled = true
    }
    
    //This function disable the button that was pressed
    func disableButtons(sender: UIButton) {
        restoreButtons()
        sender.isEnabled = false
        compareButton.isEnabled = true
        editButton.isEnabled = true
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        //To put the constraints manually
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraint(equalToConstant: 44)
        NSLayoutConstraint.activate([bottomConstraint,leftConstraint,rightConstraint,heightConstraint])
        view.layoutIfNeeded()
        secondaryMenu.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        secondaryMenu.alpha = 0
        UIView.animate(withDuration: 0.8) {
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    func hideSecondaryMenu() {
        UIView.animate(withDuration: 0.8, animations: {
            self.secondaryMenu.alpha = 0
        }) { completion in
            if completion == true {
                self.secondaryMenu.removeFromSuperview()
            }
        }
    }
}


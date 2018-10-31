//  AddTaskViewController.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/31/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import UIKit

class AddTaskViewController: UIViewController {
    @IBOutlet var taskImage: UIImageView!
    @IBOutlet var taskName: UITextField!
    @IBOutlet var taskPriority: UISegmentedControl!
    @IBOutlet var taskDescription: UITextView!
    @IBOutlet var taskDate: UIDatePicker!
    @IBOutlet var addTask: UIButton!
    
    let imagePicker = UIImagePickerController()
    var originalColor = UIColor()
    var dateSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        taskDate.minimumDate = Date()
        originalColor = addTask.tintColor
        taskDate.addTarget(self, action: #selector(dateWasSet), for: .valueChanged)
        
        taskPriority.layer.cornerRadius = 15.0
        taskPriority.layer.borderColor = addTask.tintColor.cgColor
        taskPriority.layer.borderWidth = 1.0
        taskPriority.layer.masksToBounds = true
    }
    
    @objc func dateWasSet() {
        dateSet = true
    }
    
    @IBAction func addTask(_ sender: Any) {
        guard taskName.text != "" && dateSet == true else {
            UIView.animate(withDuration: 0.5, animations: {self.view.backgroundColor = UIColor.red})
            if taskName.text == "" {
                addTask.setTitle("Task Must Have Name", for: .normal)
            } else {
                addTask.setTitle("Must Set Finish Date", for: .normal)
            }
            addTask.setTitleColor(.red , for: .normal)
            
            let timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(reset), userInfo: nil, repeats: false)
            timer.fireDate = Date().addingTimeInterval(2)
            return
        }
        
        var priority: Task.Priority
        switch taskPriority.selectedSegmentIndex {
        case 0:
            priority = .Low
        case 1:
            priority = .Normal
        case 2:
            priority = .High
        default:
            priority = .Normal
        }
        
        if taskImage.image == #imageLiteral(resourceName: "kisspng-question-mark-icon-question-mark-5a7214f2980a92.2259030715174259066228") {
            StorageEnclave.Access.addTask(Task(Name: taskName.text!, Description: taskDescription.text!, finishBy: taskDate.date, priority: priority, image: nil))
        } else {
            StorageEnclave.Access.addTask(Task(Name: taskName.text!, Description: taskDescription.text!, finishBy: taskDate.date, priority: priority, image: taskImage.image?.pngData()))
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.green
        })
        
        let timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(goBack), userInfo: nil, repeats: false)
        timer.fireDate = Date().addingTimeInterval(0.75)
    }
    
    @IBAction @objc func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func reset() {
        addTask.setTitle("Add Task", for: .normal)
        addTask.setTitleColor(originalColor, for: .normal)
        view.backgroundColor = UIColor.white
    }
}

extension AddTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertController(title: "Error", message: "The camera cannot be accessed at this time.", preferredStyle: .actionSheet)
            let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertWarning.addAction(closeAction)
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image
        taskImage.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        let cameraAlertController = UIAlertController(title: "Add Image", message: "Add a picture to your task.", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ _ in
            self.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        
        cameraAlertController.addAction(galleryAction)
        cameraAlertController.addAction(cameraAction)
        cameraAlertController.addAction(cancelAction)
        
        self.present(cameraAlertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

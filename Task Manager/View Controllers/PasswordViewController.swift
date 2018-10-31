//  ViewController.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/30/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import UIKit

class PasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var informationLabel: UILabel!
    @IBOutlet var passwordField: UITextField!
    var originalColor = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        originalColor = view.backgroundColor!
        if StorageEnclave.Access.verifyPassword(textField.text!) {
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = UIColor.green
                self.informationLabel.isHidden = true
            }
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
                self.performSegue(withIdentifier: "succedFromPasswordScreen", sender: nil)
            }
            timer.fireDate = Date().addingTimeInterval(0.75)
        } else {
            UIView.animate(withDuration: 0.5) {self.view.backgroundColor = UIColor.red}
            informationLabel.text = "Password was incorrect.\nPlease try again."
            
            let timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(reset), userInfo: nil, repeats: false)
            timer.fireDate = Date().addingTimeInterval(1)
        }
        return true
    }
    
    @objc func reset() {
        UIView.animate(withDuration: 0.5) {self.view.backgroundColor = self.originalColor}
    }
}

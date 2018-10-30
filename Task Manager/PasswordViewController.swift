//  ViewController.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/30/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import UIKit

class PasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var informationLabel: UILabel!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if StorageEnclave.Access.verifyPassword(textField.text!) {
            performSegue(withIdentifier: "succedFromPasswordScreen", sender: nil)
        } else {
            let originalColor = view.backgroundColor
            UIView.animate(withDuration: 0.5) {self.view.backgroundColor = UIColor.red}
            informationLabel.text = "Password was incorrect.\nPlease try again."
            
            let timer = Timer(timeInterval: 0, repeats: false) { _ in
                UIView.animate(withDuration: 0.5) {self.view.backgroundColor = originalColor}
            }
            timer.fireDate = Date().addingTimeInterval(1)
        }
        return true
    }
}

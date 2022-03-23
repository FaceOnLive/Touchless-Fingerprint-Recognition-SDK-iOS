//
//  ViewController.swift
//  TTVFingerDemo
//
//  Created by user on 3/15/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ret = FingerSDK.getInstance().initSDK()
        print("ret: ", ret)
    }

    @IBAction func register_clicked(_ sender: Any) {
        performSegue(withIdentifier: "showCamera", sender: 0)
    }
    
    @IBAction func verify_clicked(_ sender: Any) {
        performSegue(withIdentifier: "showCamera", sender: 1)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCamera") {
            let secondView = segue.destination as! CameraViewController
            let mode = sender as! Int
            secondView.mode = mode
        }
    }
    
    func sendData(state: Int, name: String) {
        if(state == 1) {
            ViewController.showToast(controller: self, message: "Register succeed! " + name, seconds: 1, color:.green)
        } else if(state == 2) {
            ViewController.showToast(controller: self, message: "Verify succeed! " + name, seconds: 1, color:.green)
        }
    }
    
    static func showToast(controller: UIViewController, message : String, seconds: Double, color: UIColor) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = color
        alert.view.layer.cornerRadius = 15
        controller.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}


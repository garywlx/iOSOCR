//
//  ViewController.swift
//  AzOcr
//
//  Created by Autozi01 on 2019/6/3.
//  Copyright © 2019 Autozi01. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func vinScan(_ sender: Any) {
        let controller = QGScanCodeVC(nibName:"QGScanCodeVC", bundle:nil)
        present(controller, animated: true, completion: nil)
       
    }
}


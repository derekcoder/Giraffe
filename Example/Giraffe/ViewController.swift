//
//  ViewController.swift
//  Giraffe
//
//  Created by derekcoder@gmail.com on 03/20/2018.
//  Copyright (c) 2018 derekcoder@gmail.com. All rights reserved.
//

import UIKit
import Giraffe

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let method = HttpMethod<Data>.get
        print(method)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


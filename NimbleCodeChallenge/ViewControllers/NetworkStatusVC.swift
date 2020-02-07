//
//  NetworkStatusVC.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 06/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit

class NetworkStatusVC: UIViewController {

    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    
    var errorMsg: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusLbl.text = errorMsg

        // Do any additional setup after loading the view.
    }
    
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

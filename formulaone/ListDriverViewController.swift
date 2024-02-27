//
//  ListDriverViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 27/02/2024.
//

import UIKit

class ListDriverViewController: UITableViewController {

    var meeting: Meeting?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(meeting?.meetingName)
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

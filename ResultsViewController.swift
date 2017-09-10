//
//  ResultsViewController.swift
//  HeatTransferToACircularFin
//
//  Created by ALLAN E JONES on 9/2/17.
//  Copyright © 2017 Allan Jones. All rights reserved.
//

import UIKit
import Foundation

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let n = 20    // number of segments in fin
    
    var profileArray: [Dictionary<String,String>] = []
    var radius = [Double](repeating: 0.0, count: 21)
    var hotTemp: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n1 = n + 1
        return n1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var profileDict: Dictionary<String,String> = [:]
        profileDict = profileArray[indexPath.row]
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTableViewCell
        cell.segmentNumberLabel.text = profileDict["segmentRadius"]
        cell.segmentTemperatureLabel.text = profileDict["segmentTemp"]
        return cell
    }
    // print(NSString(format:"%.3f", sum))
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "  Segment Radius, in.          Temperature, F"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    

}

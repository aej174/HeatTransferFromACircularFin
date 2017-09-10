//
//  ViewController.swift
//  HeatTransferToACircularFin
//
//  Created by Allan Jones on 6/8/15.
//  Copyright (c) 2015 Allan Jones. All rights reserved.
//    Modified on 9/3/17
//

import UIKit
import Foundation

class ViewController: UIViewController {
  
    @IBOutlet weak var finODTextField: UITextField!
    @IBOutlet weak var finIDTextField: UITextField!
    @IBOutlet weak var finThicknessTextField: UITextField!
    @IBOutlet weak var finConductivityTextField: UITextField!
    
    @IBOutlet weak var hotFluidTempTextField: UITextField!
    @IBOutlet weak var coldFluidTempTextField: UITextField!
    @IBOutlet weak var heatTransferCoeffTextField: UITextField!
    
    @IBOutlet weak var heatTransferRateLabel: UILabel!
    @IBOutlet weak var finEfficiencyLabel: UILabel!
   
    let pi = 3.1415926
  
    let n1 = 21  //n = numberOfSegments plus 1
  
    let dr: Double = 0.0
    
    var segments: [Segment] = []
    
    var segment = Segment()
    
    var profileDict: Dictionary<String,String> = [:]
    var profileArray: [Dictionary<String,String>] = []
    
    var temperatures = [Double](repeating: 0.0, count: 21)
    var avgRadius = [Double](repeating: 0.0, count: 21)
    var radius = [Double](repeating: 0.0, count: 21)

    var hotTemp: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for j in 1..<(n1) {
            segment.radius = radius[j]
            segment.temperature = temperatures[j]
            segments.append(segment)
            
        }
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: Start calculations
    
    @IBAction func calculateButton(_ sender: UIButton) {
        //read data
        let hotTemperature = Double((hotFluidTempTextField.text as String?)!)
        let ambientTemperature = Double((coldFluidTempTextField.text as String?)!)
        let finCoefficient = Double((heatTransferCoeffTextField.text as String?)!)
        let finODIn = Double((finODTextField.text as String?)!)
        let finIDIn = Double((finIDTextField.text as String?)!)
        let thicknessOfFinIn = Double((finThicknessTextField.text as String?)!)
        let finConductivity = Double((finConductivityTextField.text as String?)!)
    
        let finID = finIDIn! / 12.0
        let finOD = finODIn! / 12.0
        let finThickness = thicknessOfFinIn! / 12.0
      
        print("hot temperature = \(String(describing: hotTemperature)) F")
        print("ambient temperature = \(String(describing: ambientTemperature)) F")
        print("finCoefficient = \(String(describing: finCoefficient)) BTU/hr-ft2-F")
        print("finID = \(12.0 * finID) in")
        print("finOD = \(12.0 * finOD) in")
        print("finThickness = \(12.0 * finThickness) in")
        print("finConductivity = \(String(describing: finConductivity)) BTU/hr-ft-F")
        
        let n = n1 - 1
        print("Number of segments = \(n)")
        
        hotTemp = hotTemperature!
    
        //Mark: Set up fin radii
        
        radius = segmentRadii(n: n, finOD: finOD, finID: finID)
        
        let dr = (finOD - finID) / (2.0 * Double(n))
        
        for j in 1..<(n1) {
            avgRadius[j] = radius[j] - dr / 2.0
            print("j = \(j), segment radius = \(radius[j]), avg radius = \(avgRadius[j])")
        }
                
        //MARK: Set up heat balance equations
        
        let phi = finConductivity! * finThickness / dr
        print("phi = \(phi)")
            
        var aa = [Double](repeating: 0.0, count: n1)
        var bb = [Double](repeating: 0.0, count: n1)
        var cc = [Double](repeating: 0.0, count: n1)
        var dd = [Double](repeating: 0.0, count: n1)
    
        cc[1] = 0.0
        aa[1] = phi * radius[1] + 2.0 * phi * radius[0] + 2.0 * avgRadius[1] * dr * finCoefficient!
        bb[1] = -phi * radius[1]
        dd[1] = 2.0 * phi * radius[0] * hotTemperature! + 2.0 * avgRadius[1] * dr * finCoefficient! * ambientTemperature!
        print("j= \(1), cc= \(cc[1]), aa= \(aa[1]), bb= \(bb[1]), dd= \(dd[1])")
        
        for j in 2..<n {
            cc[j] = -phi * radius[j - 1]
            aa[j] = 2.0 * avgRadius[j] * (phi + dr * finCoefficient!)
            bb[j] = -phi * radius[j]
            dd[j] = 2.0 * avgRadius[j] * dr * finCoefficient! * ambientTemperature!
            print("j= \(j), cc= \(cc[j]), aa= \(aa[j]), bb= \(bb[j]), dd= \(dd[j])")
        }
        
        cc[n] = -phi * radius[n - 1]
        aa[n] = phi * radius[n - 1] + 2.0 * avgRadius[n] * dr * finCoefficient!
        bb[n] = 0.0
        dd[n] = 2.0 * avgRadius[n] * dr * finCoefficient! * ambientTemperature!
        print("j= \(n), cc= \(cc[n]), aa= \(aa[n]), bb= \(bb[n]), dd= \(dd[n])")
        
        temperatures = thomasAlgorithm(n, aa: aa, bb: bb, cc: cc, dd: dd)

        let heatIn = (2.0 * pi * radius[0] * finConductivity! * finThickness) * (hotTemperature! - temperatures[1]) / (dr / 2.0)
        var heatOut = 0.0
        var roundTemp = Double(round(100 * hotTemperature! / 100))
        print("i= 0, temperature = \(roundTemp)")
        for i in 1..<(n1) {
            roundTemp = Double(round(100 * temperatures[i] / 100))
            print("i= \(i), temperature = \(roundTemp)")
            heatOut = heatOut + (2.0 * pi * avgRadius[i] * dr) * (2.0 * finCoefficient! * (temperatures[i] - ambientTemperature!))
        }
        let roundHeatIn = Double(round(100 * heatIn) / 100)
        let roundHeatOut = Double(round(100 * heatOut) / 100)
        print("Heat in = \(roundHeatIn), Heat out = \(roundHeatOut)")
    
        let avgHeat = (heatIn + heatOut) / 2.0
        let yy = Double(round(100 * avgHeat) / 100)
        print("Avg Heat = \(yy), BTU/hr per fin")
        
        let rout = finOD / 2.0
        let rin = finID / 2.0
        let idealHeat = 4.0 * pi * (rout * rout - rin * rin) * finCoefficient! * (hotTemperature! - ambientTemperature!)
        let zz = Double(round(100 * (100.0 * avgHeat / idealHeat)) / 100)
        print("Fin Efficiency = \(zz) %")
        
        heatTransferRateLabel.text = "\(yy)"
        finEfficiencyLabel.text = "\(zz)"
    }
    
    /*
 let nf = NSNumberFormatter()
 nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
 nf.maximumFractionDigits = 2
 println(nf.stringFromNumber(0.33333)) // prints 0.33 */
     
    override func prepare(for Segue: UIStoryboardSegue, sender: Any?) {
        if Segue.identifier == "toResultsVC" {
            let resultsVC = Segue.destination as! ResultsViewController
            for j in 0..<n1 {
                resultsVC.radius[j] = radius[j]
                print("j = \(j), radius = \(resultsVC.radius[j])")
            }
            let nf = NumberFormatter()
            nf.usesSignificantDigits = true
            nf.minimumFractionDigits = 3

            var xz: Double = 0.0
            var yz: Double = 0.0
            resultsVC.hotTemp = hotTemp
            //print((nf.string(from: 0.5)!))
            print("xz = \(xz)")
            yz = Double(round(100 * resultsVC.hotTemp) / 100)
            resultsVC.profileArray.append(["segmentRadius":"\(xz)", "segmentTemp":"\(yz)"])
            print("segmentRadius", "\(xz)", "segmentTemp", "\(yz)")
            for j in 1..<n1  {
                xz = Double(nf.string(from: (resultsVC.radius[j] * 12.0)))
                yz = Double(round(100 * temperatures[j]) / 100)
                resultsVC.profileArray.append(["segmentRadius":"\(xz)", "segmentTemp":"\(yz)"])
                print("segmentRadius  ", NSString(format:"%.3f", xz), "segmentTemp", "\(yz)")
            }
        }

    }
    
    
    @IBAction func tabularResultsPressed(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "toResultsVC", sender: self)
    }
    
    
    func segmentRadii(n: Int, finOD: Double, finID: Double) -> [Double] {
        let dr = (finOD - finID) / (2.0 * Double(n))
        
        // Set up radius array
       
        for j in 0..<(n + 1) {
            if j == 0 {
                radius[j] = finID / 2.0
            }
            else if j == n {
                radius[j] = finOD / 2.0
            }
            else {
                radius[j] = radius[j - 1] + dr
            }
            print("j = \(j), segment radius = \(radius[j])")
        }
        
        return radius
    }
    
   
    
    // MARK: Thomas Algorithm for solving simultaneous linear equations in a tridiagonal matrix
    
    /* The equations to be solved are of the form: cc(i) * x(i-1) + aa(i) * x(i) + bb(i) * x(i+1) = dd(i)
     where x(i) are the values of the unknown array x. */

    func thomasAlgorithm(_ n: Int, aa:[Double], bb:[Double], cc:[Double], dd:[Double]) -> [Double] {
        
        var xx = [Double](repeating: 0.0, count: n1)
        var qq = [Double](repeating: 0.0, count: n1)
        var ww = [Double](repeating: 0.0, count: n1)
        var gg = [Double](repeating: 0.0, count: n1)
        
        for j in 1..<(n1) {
            if j == 1 {
                ww[j] = aa[j]
                gg[j] = dd[j] / ww[j]
            }
            else {
                qq[j - 1] = bb[j - 1] / ww[j - 1]
                ww[j] = aa[j] - cc[j] * qq[j - 1]
                gg[j] = (dd[j] - cc[j] * gg[j - 1]) / ww[j]
            }
        }
        xx[n] = gg[n]
        temperatures[n] = xx[n]
        
        for i in ((0 + 1)...n - 1).reversed() {
            
            xx[i] = gg[i] - qq[i] * xx[i + 1]
            temperatures[i] = xx[i]
        }
        return temperatures
    }

}

/* //MARK: UITableViewDataSource
 
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return numberOfSegments
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let profileDict:Dictionary = profileArray[(indexPath as NSIndexPath).row]
 let cell: ProfileCell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! ProfileCell
 cell.segmentNumberLabel.text = profileDict["segmentNumber"]
 cell.segmentTemperatureLabel.text = profileDict["segmentTemp"]
 return cell
 }
 
 func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
 return 40.0
 }
 
 func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
 let titleHeader: String = "Segment No.              Temperature, F"
 return titleHeader
 
 }

 //MARK: Update tableView
 
 profileArray = []
 
 for j in 0..<numberOfSegments {
 if j == 0 {
 segments[j].temperature = hotTemperature!
 }
 else {
 segments[j].temperature = temperatures[j]
 }
 
 let y = Double(round(100 * segments[j].temperature) / 100)
 print("j = \(j), temperature = \(y)")
 profileArray.append(["segmentNumber":"\(j)", "segmentTemp":"\(y)"])
 }
 print("\(profileArray.count) segments in array")
 
 self.tableView.reloadData()
 }

*/

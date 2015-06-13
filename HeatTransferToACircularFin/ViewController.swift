//
//  ViewController.swift
//  HeatTransferToACircularFin
//
//  Created by Allan Jones on 6/8/15.
//  Copyright (c) 2015 Allan Jones. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var finODTextField: UITextField!
  @IBOutlet weak var finIDTextField: UITextField!
  @IBOutlet weak var finThicknessTextField: UITextField!
  @IBOutlet weak var finThermalConductivityTextField: UITextField!
  @IBOutlet weak var heatTransferCoefficientTextField: UITextField!
  @IBOutlet weak var hotFluidTemperatureTextField: UITextField!
  @IBOutlet weak var ambientTemperatureTextField: UITextField!
  @IBOutlet weak var finHeatTransferRateTextField: UITextField!
  @IBOutlet weak var finEfficiencyTextField: UITextField!
  
  @IBOutlet weak var tableView: UITableView!
  
  let pi = 3.1415926
  
  let numberOfSegments = 21
  
  let dr: Double = 0.0
    
  var segments: [Segment] = []
    
  var segment = Segment()
    
  var temperatures = [Double](count: 21, repeatedValue: 100.0)
  var avgRadius = [Double](count: 21, repeatedValue: 0.0)
    
  var profileArray: [Dictionary<String,String>] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    
    for var i = 0; i<numberOfSegments; ++i {
      segment.temperature = temperatures[i]
      segments.append(segment)
      profileArray.append(["segmentNumber":"\(i)", "segmentTemp":"\(segments[i].temperature)"])
      //println("segmentNumber = \(i), segmentTemp =  \(segments[i].temperature)")
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: UITableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfSegments
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let profileDict:Dictionary = profileArray[indexPath.row]
    var cell: ProfileCell = tableView.dequeueReusableCellWithIdentifier("myCell") as! ProfileCell
    cell.segmentNumberLabel.text = profileDict["segmentNumber"]
    cell.segmentTemperatureLabel.text = profileDict["segmentTemp"]
    return cell
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40.0
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let titleHeader: String = "Segment No.              Segment Temperature, F"
    return titleHeader
  }
  
  //MARK: Start calculations
  
  @IBAction func calculateButtonPressed(sender: UIButton) {
    //read data
    let hotTemperature = Double((hotFluidTemperatureTextField.text as NSString).doubleValue)
    let ambientTemperature = Double((ambientTemperatureTextField.text as NSString).doubleValue)
    let finCoefficient = Double((heatTransferCoefficientTextField.text as NSString).doubleValue)
    let finODIn = Double((finODTextField.text as NSString).doubleValue)
    let finIDIn = Double((finIDTextField.text as NSString).doubleValue)
    let thicknessOfFinIn = Double((finThicknessTextField.text as NSString).doubleValue)
    let finConductivity = Double((finThermalConductivityTextField.text as NSString).doubleValue)
    
    let finID = finIDIn / 12.0
    let finOD = finODIn / 12.0
    let finThickness = thicknessOfFinIn / 12.0
      
    println("hot temperature = \(hotTemperature) F")
    println("ambient temperature = \(ambientTemperature) F")
    println("finCoefficient = \(finCoefficient) BTU/hr-ft2-F")
    println("finID = \(12.0 * finID) in")
    println("finOD = \(12.0 * finOD) in")
    println("finThickness = \(12.0 * finThickness) in")
    println("finConductivity = \(finConductivity) BTU/hr-ft-F")
    
    let dr = (finOD - finID) / (2.0 * Double(numberOfSegments - 1))
    
    // Set up avgRadius array
    
    println("Number of segments = \(segments.count)")
    
    for var i = 0; i<segments.count; ++i {
      if i == 0 {
        segments[i].radius = 0.0
      }
      else if i == 1 {
        segments[i].radius = finID / 2.0
      }
      else {
        segments[i].radius = segments[i-1].radius + dr
      }
      println("i = \(i), segment radius = \(segments[i].radius)")
    }
    
    for var j = 0; j<segments.count; ++j {
      avgRadius[j] = segments[j].radius + dr / 2.0
      println("j = \(j), segment radius = \(segments[j].radius), avg radius = \(avgRadius[j])")
    }
    
    //MARK: Set up heat balance equations
    
    let phi = 2.0 * finCoefficient * dr * dr / (finConductivity * finThickness)
    println("phi = \(phi)")
    let range = segments.count - 1
    
    var aa = [Double](count:segments.count, repeatedValue: 0.0)
    var bb = [Double](count:segments.count, repeatedValue: 0.0)
    var cc = [Double](count:segments.count, repeatedValue: 0.0)
    var dd = [Double](count:segments.count, repeatedValue: 0.0)
      
    for j in 1..<numberOfSegments {
      if j == 1 {
        cc[j] = 0.0
        aa[j] = 2.0 * segments[1].radius + segments[2].radius + phi * avgRadius[1]
        bb[j] = -segments[2].radius
        dd[j] = 2.0 * segments[1].radius * hotTemperature + phi * avgRadius[1] * ambientTemperature
      }
      else if j == range {
        cc[j] = -segments[range].radius
        aa[j] = segments[range].radius + phi * avgRadius[range]
        bb[j] = 0.0
        dd[j] = avgRadius[range] * phi * ambientTemperature
      }
      else {
        cc[j] = -segments[j].radius
        aa[j] = segments[j].radius + segments[j+1].radius + phi * avgRadius[j]
        bb[j] = -segments[j+1].radius
        dd[j] = avgRadius[j] * phi * ambientTemperature
      }
      println("j= \(j), cc= \(cc[j]), aa= \(aa[j]), bb= \(bb[j]), dd= \(dd[j])")
    }
    
    temperatures = thomasAlgorithm(range, aa: aa, bb: bb, cc: cc, dd: dd)

    let heatIn = (2.0 * pi * segments[1].radius * finConductivity * finThickness) * (hotTemperature - temperatures[1]) / (dr / 2.0)
    var heatOut = 0.0
    for i in 1..<numberOfSegments {
      var roundTemp = Double(round(100 * temperatures[i] / 100))
      println("i= \(i), temperature= \(roundTemp)")
      heatOut = heatOut + (2.0 * pi * avgRadius[i] * dr) * (2.0 * finCoefficient * (temperatures[i] - ambientTemperature))
    }
    let roundHeatIn = Double(round(100 * heatIn) / 100)
    let roundHeatOut = Double(round(100 * heatOut) / 100)
    println("Heat in = \(roundHeatIn), Heat out = \(roundHeatOut)")
    
    let avgHeat = (heatIn + heatOut) / 2.0
    let yy = Double(round(100 * avgHeat) / 100)
    println("Avg Heat = \(yy), BTU/hr-ft")
        
    let rout = finOD / 2.0
    let rin = finID / 2.0
    let idealHeat = 2.0 * pi * (rout * rout - rin * rin) * finCoefficient * (hotTemperature - ambientTemperature)
    let finEfficiency = 100.0 * avgHeat / idealHeat
    let zz = Double(round(100 * finEfficiency) / 100)
    println("Fin Efficiency = \(zz) %")
        
    self.finHeatTransferRateTextField.text = "\(yy)"
    self.finEfficiencyTextField.text = "\(zz)"
    
    //MARK: Update tableView
    
    profileArray = []
    
    for j in 0..<numberOfSegments {
      if j == 0 {
        segments[j].temperature = hotTemperature
      }
      else {
        segments[j].temperature = temperatures[j]
      }
      
      let y = Double(round(100 * segments[j].temperature) / 100)
      println("j = \(j), temperature = \(y)")
      profileArray.append(["segmentNumber":"\(j)", "segmentTemp":"\(y)"])
    }
    println("\(profileArray.count) segments in array")
    
    self.tableView.reloadData()
  }
  
  func thomasAlgorithm(range: Int, aa:[Double], bb:[Double], cc:[Double], dd:[Double]) -> [Double] {
        
        var xx = [Double](count:range + 1, repeatedValue: 0.0)
        var qq = [Double](count:range + 1, repeatedValue: 0.0)
        var ww = [Double](count:range + 1, repeatedValue: 0.0)
        var gg = [Double](count:range + 1, repeatedValue: 0.0)
        
        for j in 1..<(range + 1) {
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
        xx[range] = gg[range]
        
        for var i = range - 1; i > 0; i-- {
      
            xx[i] = gg[i] - qq[i] * xx[i + 1]
        }
        return xx
    }

  


}


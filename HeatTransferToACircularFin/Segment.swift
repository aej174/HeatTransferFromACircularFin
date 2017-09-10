//
//  Segment.swift
//  HeatTransferToACircularFin
//
//  Created by Allan Jones on 6/8/15.
//  Copyright (c) 2015 Allan Jones. All rights reserved.
//

import Foundation

struct Segment {
    
    var index: Int = 0
    var temperature: Double = 0.0
    var conductivity: Double = 0.0
    var coefficient: Double = 0.0
    var thickness: Double = 0.0
    var radius: Double = 0.0
    var avgRadius: Double = 0.0
    
    var segments = [Segment]()
    
    
}

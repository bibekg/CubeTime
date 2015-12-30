////
////  SolveMO.swift
////  CubeTime
////
////  Created by Bibek Ghimire on 12/28/15.
////  Copyright © 2015 Bibek. All rights reserved.
////

import Foundation
import CoreData

@objc(Solve)

class Solve: NSManagedObject {
    @NSManaged var time: Double
    @NSManaged var scramble: String
    @NSManaged var date: NSDate
    @NSManaged var inspectionTime: Int32
}
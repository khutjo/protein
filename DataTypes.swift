//
//  DataTypes.swift
//  protein
//
//  Created by Khutjo MAPUTLA on 2019/11/15.
//  Copyright © 2019 WeThinkCode. All rights reserved.
//

import Foundation

struct atomdata {
    var atomid: String
    var atomX: Float?
    var atomY: Float?
    var atomZ: Float?
    var atomtype: String
}
struct atomlinkdata {
    var MainAtom: Int
    var AtomLinks: [Int]
}

//
//  BitMaskCategory.swift
//  myBasketballARApp
//
//  Created by Виктор on 14/07/2019.
//  Copyright © 2019 SwiftViktor. All rights reserved.
//


struct BitMaskCategory: OptionSet {
    let rawValue: Int
    
    static let none = BitMaskCategory(rawValue: 1 << 0)
    static let boll = BitMaskCategory(rawValue: 1 << 1)
    static let backboard  = BitMaskCategory(rawValue: 1 << 2)
    static let bottonHoop = BitMaskCategory(rawValue: 1 << 3)
    static let middleHoop = BitMaskCategory(rawValue: 1 << 4)
    static let topHoop = BitMaskCategory(rawValue: 1 << 5)
    static let worldBox = BitMaskCategory(rawValue: 1 << 6)
}


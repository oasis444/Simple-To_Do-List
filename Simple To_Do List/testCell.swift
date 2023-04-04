//
//  testCell.swift
//  Simple To_Do List
//
//  Copyright (c) 2023 oasis444. All right reserved.
//

import UIKit

class testCell: UICollectionViewCell {
    
    @IBOutlet weak var testLabel: UILabel!
    
    
    func configure(info: Task) {
        testLabel.text = info.title
    }
}

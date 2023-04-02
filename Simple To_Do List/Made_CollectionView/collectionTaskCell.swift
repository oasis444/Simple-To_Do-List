//
//  collectionTaskCell.swift
//  Simple To_Do List
//
//  Copyright (c) 2023 oasis444. All right reserved.
//

import UIKit

class collectionTaskCell: UICollectionViewCell {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var checkMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(info: Task) {
        taskLabel.text = info.title
        if info.done {
            checkMark.isHidden = false
        } else {
            checkMark.isHidden = true
        }
    }
}

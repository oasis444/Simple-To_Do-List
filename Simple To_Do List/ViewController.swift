//
//  ViewController.swift
//  Simple To_Do List
//
//  Copyright (c) 2023 oasis444. All right reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var TableLable: UILabel!
    @IBOutlet weak var CollectionLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

    private func configure() {
        TableLable.isUserInteractionEnabled = true
        CollectionLable.isUserInteractionEnabled = true
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(goTableVC))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goCollectionVC))
        TableLable.addGestureRecognizer(tapGesture1)
        CollectionLable.addGestureRecognizer(tapGesture2)
    }
    
    @objc func goTableVC() {
        guard let vc = storyboard?.instantiateViewController(identifier: "TableVC") else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goCollectionVC() {
        guard let vc = storyboard?.instantiateViewController(identifier: "CollectionVC") else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}

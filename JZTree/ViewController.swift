//
//  ViewController.swift
//  JZTree
//
//  Created by wizet on 2019/10/26.
//  Copyright © 2019 wizet. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var hv = JZHierarchicalView.init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.view.addSubview(hv)
        hv.backgroundColor = UIColor.orange
        hv.translatesAutoresizingMaskIntoConstraints = false
        hv.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        hv.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        hv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        hv.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        
        
        let rootTreeNode: JZTreeNode = JZTreeNode.rootNode()
        
        let l2 = JZTreeNode.node()
        let l2_1 = JZTreeNode.node()
        l2_1.chlidren = [JZTreeNode.leaf()]
        
        let l2_2 = JZTreeNode.node()
        l2_2.chlidren = [JZTreeNode.leaf(), JZTreeNode.leaf()]
        
        rootTreeNode.chlidren = [l2, l2_1, l2_2]
        
        
        let l3 = JZTreeNode.node()
        l3.chlidren = [JZTreeNode.leaf()]
        l2.chlidren = [l3]
        
        
        let l4 = JZTreeNode.node()
        let l4_1 = JZTreeNode.node()
        let l4_2 = JZTreeNode.node()
        l4.chlidren = [JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf()]
        l4_1.chlidren = [JZTreeNode.leaf(), JZTreeNode.leaf()]
        
        
        let l5 = JZTreeNode.node()
        l4_2.chlidren = [JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), JZTreeNode.leaf(), l5]
        l5.chlidren = [JZTreeNode.leaf()]
        
        l3.chlidren = [l4, l4_1, l4_2]
        
        print("深度为：\(rootTreeNode.depth())")
        
        self.hv.rootTreeNode = rootTreeNode
        self.hv.reload()
    }
    
    
}


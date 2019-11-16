//
//  ViewController.swift
//  JZTree
//
//  Created by wizet on 2019/10/26.
//  Copyright © 2019 wizet. All rights reserved.
//

import UIKit

class ViewController: UIViewController, JZTreeViewProtocol {
    
    var hv = JZTreeView.init(frame: .zero)
    
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
        
        
        
        let rootTreeNode: JZTreeNode = JZTreeNode.rootNode(JZTreeTestCell.rid)
        
        let l2 = JZTreeNode.node(JZTreeTestCell.rid)
        let l2_1 = JZTreeNode.node(JZTreeTestCell.rid)
        l2_1.chlidren = [JZTreeNode.leaf(JZTreeTestCell.rid)]
        
        let l2_2 = JZTreeNode.node(JZTreeTestCell.rid)
        l2_2.chlidren = [JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid)]
        
        let l2_3 = JZTreeNode.leaf(JZTreeTestCell.rid)
        rootTreeNode.chlidren = [l2, l2_1, l2_2, l2_3]
        
        
        let l3 = JZTreeNode.node(JZTreeTestCell.rid)
        l3.chlidren = [JZTreeNode.leaf(JZTreeTestCell.rid)]
        l2.chlidren = [l3]
        
        
        let l4 = JZTreeNode.node(JZTreeTestCell.rid)
        let l4_1 = JZTreeNode.node(JZTreeTestCell.rid)
        let l4_2 = JZTreeNode.node(JZTreeTestCell.rid)
        l4.chlidren = [JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid)]
        l4_1.chlidren = [JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid)]
        
        
        let l5 = JZTreeNode.node(JZTreeTestCell.rid)
        l4_2.chlidren = [JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), JZTreeNode.leaf(JZTreeTestCell.rid), l5]
        l5.chlidren = [JZTreeNode.leaf(JZTreeTestCell.rid)]
        
        l3.chlidren = [l4, l4_1, l4_2]
        
        print("深度为：\(rootTreeNode.depth())")
        hv.delegate = self
        self.hv.registerCellClass(cellTypePairs: [JZTreeTestCell.rid : JZTreeTestCell.self])
        
        // 更新的操作
        self.hv.rootTreeNode = rootTreeNode
        self.hv.reload()
        
    }
    
    
    func collectionView(cell: UICollectionViewCell, cellForItem: JZTreeNode) {
        if let cell = cell as? JZTreeTestCell {
            cell.update(treeNode: cellForItem)
            
            cell.longPressGestureClosure = { [weak self] in
                guard let self = self else { return }
                
                //
            }
        }
    }
    func collectionView(cell: UICollectionViewCell, didSelectItem: JZTreeNode) {
        if let cell = cell as? JZTreeTestCell {
            UIView.animate(withDuration: 0.25) {
                cell.update(treeNode: didSelectItem)
            }
        }
    }
    
}


//
//  JZTreeView.swift
//  JZTreeView
//
//  Created by wizet on 2019/10/26.
//  Copyright © 2019 wizet. All rights reserved.
//

import Foundation
import UIKit


@objc protocol JZTreeViewProtocol: NSObjectProtocol {
    @objc func collectionView(cell: UICollectionViewCell, cellForItem treeNode: JZTreeNode)
    @objc func collectionView(cell: UICollectionViewCell, didSelectItem treeNode: JZTreeNode)
}


/// 分等级视图 (最好用iOS13 colectionView新的接口实现)
public final class JZTreeView: UIView {
    
    weak var delegate: JZTreeViewProtocol? = nil
    
    /// .isExpanded 必须为true， rootNode 是不绘制的，所以不会成为cell的一部分，因此rid随意设置即可
    public var rootTreeNode: JZTreeNode = JZTreeNode.node("")
    
    public private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 44.0)
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新rootTreeNode之后必须调用reload以刷新数据源以及更新准备动作
    public func reload() {
        // 重新编链
        self.rootTreeNode.lines = self.rootTreeNode.makeLines(level: self.rootTreeNode.level)
        self.collectionView.reloadData()
    }
    
    /// 删除节点（如果是leaf类型只删除自己，如果是node类型则包括node下的node以leaf）
    //FIXME: 待完成 考虑插入和删除的应如何操作
//    public func deleteTreeNode(treeNode: JZTreeNode) {
//        // 保存旧模型的轨迹 - 对比新模型的轨迹，代码处理treeNode的数据
//        let lines = self.rootTreeNode.lines
//        if lines.contains(treeNode) == true {
//            if let index = lines.firstIndex(of: treeNode)
//                , lines.count > index {
//                // 执行删除操作
//                let at = self.childrenIndexPath(index: index, treeNode: treeNode)
//                #if DEBUG
//                print("删除位置为：\(at)的treeNode")
//                #endif
//
//            }
//        } else {
//            // 删除不存在的节点
//        }
//    }
//
//    /// 插入的位置 （插入到末尾）
//    public func insertTreeNode(treeNode: JZTreeNode, atNode: JZTreeNode) {
//        if atNode.isNode {
//            let lines = self.rootTreeNode.lines
//            if lines.contains(atNode) == true {
//                if let index = lines.firstIndex(of: treeNode)
//                               , lines.count > index {
//                    let at = self.childrenIndexPath(index: index, treeNode: treeNode)
//
//                    self.rootTreeNode.lines = self.rootTreeNode.makeLines(level: self.rootTreeNode.level)
//                    if at.count > 0 {
//                        self.collectionView.insertItems(at: at)
//                    }
//                    #if DEBUG
//                    print("插入位置为：\(at)的treeNode")
//                    #endif
//                    atNode.chlidren.append(treeNode)
//                }
//            }
//        } else {
//            // 智能插入到node中
//        }
//    }
}


extension JZTreeView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rootTreeNode.lines.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let treeNode = self.rootTreeNode.lines[indexPath.row]
        let rid = treeNode.rid
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rid, for: indexPath)

        self.delegate?.collectionView(cell: cell, cellForItem: treeNode)
        
        return cell
    }
}

extension JZTreeView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let treeNode = self.rootTreeNode.lines[indexPath.row]
        
        if treeNode.isNode == true {
            if treeNode.isExpanded == true {
                // 收缩动画
                let at = self.childrenIndexPath(index: indexPath.row, treeNode: treeNode)
                treeNode.isExpanded = false
                
                
                self.rootTreeNode.lines = self.rootTreeNode.makeLines(level: self.rootTreeNode.level)
                if at.count > 0 {
                    self.collectionView.deleteItems(at: at)
                }
            } else {
                // 伸展动画
                treeNode.isExpanded = true
                let at = self.childrenIndexPath(index: indexPath.row, treeNode: treeNode)
                
                
                self.rootTreeNode.lines = self.rootTreeNode.makeLines(level: self.rootTreeNode.level)
                if at.count > 0 {
                    self.collectionView.insertItems(at: at)
                }
            }
        }
        
        /// 刷新UI
        if let cell = collectionView.cellForItem(at: indexPath) {
            self.delegate?.collectionView(cell: cell, didSelectItem: treeNode)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    /// 计算treeNode中children在lines中的所有位置
    private func childrenIndexPath(index: Int, treeNode: JZTreeNode)->[IndexPath] {
        var at: [IndexPath] = []
        if treeNode.isNode && treeNode.isExpanded == true {
            
            var i = index
            for value in treeNode.chlidren {
                i = i + 1
                at.append(IndexPath.init(row: i, section: 0))
                if value.isNode && value.isExpanded == true {
                    at.append(contentsOf: self.childrenIndexPath(index: i, treeNode: value))
                    i = i + value.chlidren.count
                }
            }
        }
        return at
    }
    
    
    /// cell 注册
    /// - Parameter cellTypePairs: key as Cell Reuse Identifier，value as cell type
    public func registerCellClass(cellTypePairs: [String: UICollectionViewCell.Type]) {
        for element in cellTypePairs {
            collectionView.register(element.value, forCellWithReuseIdentifier: element.key)
            #if DEBUG
            print("注册了cell: \(String.init(describing: element.self))")
            #endif
        }
    }
}



/// JZTreeView 使用的模型
@objc public class JZTreeNode: NSObject {
    
    /// Cell Reuse Identifier
    let rid: String
    
    public init(_ rid: String) {
        self.rid = rid
        super.init()
    }
    
    /// 初始化一个节点类型
    static func node(_ rid: String)->JZTreeNode {
        let treeNode =  JZTreeNode(rid)
        treeNode.isNode = true
        treeNode.isExpanded = false
        return treeNode
    }
    
    /// 初始化rootNode的类型，注意isExpanded必须为true
    static func rootNode(_ rid: String)->JZTreeNode {
        let treeNode = JZTreeNode(rid)
        treeNode.isNode = true
        treeNode.isExpanded = true
        return treeNode
    }
    
    /// 初始化一个叶子类型
    static func leaf(_ rid: String)->JZTreeNode {
        let treeNode =  JZTreeNode(rid)
        return treeNode
    }
    
    /// 大纲等级（cell处理分层状态的标志）
    var level: Int = 0
    
    /// 下一层级的元素，如果是leaf类型则chlidren是无效的
    ///
    /// chlidren.element.level = self.level - 1
    var chlidren: [JZTreeNode] = []
    
    /// 使用展开
    var isExpanded = true
    
    /// 仅用于rootTreeNode
    fileprivate var lines: [JZTreeNode] = []
    
    /// 判定为是否为节点
    /// 自定义此行为， 以此为依据决定chlidren，是否可用
    var isNode = false
    func isLeaf()->Bool {
        return !self.isNode
    }
    
    
    /// 计算层级的深度（包括不展开的部分）， 不建议频繁调用此方法
    /// 不包含根节点，所以-1
    func depth()->Int {
        return self.calculateDepth() - 1
    }
    
    
    /// 计算深度
    private func calculateDepth()->Int {
        let treeNode = self
        // 非展开的node类型在计算深度时，可看作是leaf
        if treeNode.isNode == true {
            
            var maxCollection: [Int] = []
            for element in treeNode.chlidren {
                maxCollection.append(element.calculateDepth())
            }
            
            var result = maxCollection.max() ?? 0
            result = result + 1
            
            return result
        } else {
            return 1
        }
    }
    
    
    /// 编链，root用于处理数据源
    @discardableResult
    func makeLines(level: Int) -> [JZTreeNode] {
        var lines: [JZTreeNode] = []
        let treeNode = self
        
        if treeNode.isNode && treeNode.isExpanded == true {
            for element in treeNode.chlidren {
                lines.append(element)
                element.level = level
                if element.isNode
                    && element.isExpanded == true
                    && element.chlidren.count > 0 {
                    lines.append(contentsOf: element.makeLines(level: level + 1))
                }
            }
        }
        
        return lines
    }
}





public class JZTreeCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.state == .began || otherGestureRecognizer.state == .possible {
            if let classForCoder = otherGestureRecognizer.view?.classForCoder
                , "UILayoutContainerView" == "\(classForCoder)" {
                self.panGestureRecognizer.require(toFail: otherGestureRecognizer)
                return true
            }
        }
        return false
    }
}

//
//  JZHierarchicalView.swift
//  JZHierarchicalView
//
//  Created by wizet on 2019/10/26.
//  Copyright © 2019 wizet. All rights reserved.
//

import Foundation
import UIKit


/// 分等级视图 (最好用iOS13 colectionView新的接口实现)
public final class JZHierarchicalView: UIView {
    
    /// .isExpanded 必须为truue
    public var rootTreeNode: JZTreeNode = JZTreeNode.node()
    
    public private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 44.0)
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(JZTreeCollectionViewCell.self, forCellWithReuseIdentifier: JZTreeCollectionViewCell.rid)
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
}


extension JZHierarchicalView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rootTreeNode.lines.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let treeNode = self.rootTreeNode.lines[indexPath.row]
        let rid = treeNode.rid
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rid, for: indexPath)
        if let cell = cell as? JZTreeCollectionViewCell {
            cell.update(treeNode: treeNode)
        }
        
        return cell
    }
}


extension JZHierarchicalView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let treeNode = self.rootTreeNode.lines[indexPath.row]
        
        if treeNode.isNode == true {
            if treeNode.isExpanded == true {
                // 收缩动画
                let at = self.childrenIndexPath(index: indexPath.row, treeNode: treeNode)
                treeNode.isExpanded = false
                
                self.rootTreeNode.lines = self.rootTreeNode.makeLines(level: self.rootTreeNode.level)
                self.collectionView.deleteItems(at: at)
            } else {
                // 伸展动画
                treeNode.isExpanded = true
                let at = self.childrenIndexPath(index: indexPath.row, treeNode: treeNode)
                
                
                self.rootTreeNode.lines = self.rootTreeNode.makeLines(level: self.rootTreeNode.level)
                self.collectionView.insertItems(at: at)
            }
        }
        
        /// 刷新UI
        if let cell = collectionView.cellForItem(at: indexPath) as? JZTreeCollectionViewCell {
            UIView.animate(withDuration: 0.25) {
                cell.update(treeNode: treeNode)
            }
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
}





public class JZTreeNode {
    
    /// 复用ID，可通过修改它达到使用自定义cell的目的（注意，自定义cell均需要继承JZTreeCollectionViewCell
    /// FIXME：未完成：当然，也可以自定义类型cell，需要将cell需要处理的接口作为回调，在外部实现， 注册接口外放
    var rid = JZTreeCollectionViewCell.rid
    
    /// 初始化一个节点类型
    static func node()->JZTreeNode {
        let treeNode =  JZTreeNode()
        treeNode.isNode = true
        treeNode.isExpanded = false
        return treeNode
    }
    
    /// 初始化rootNode的类型，注意isExpanded必须为true
    static func rootNode()->JZTreeNode {
        let treeNode =  JZTreeNode()
        treeNode.isNode = true
        treeNode.isExpanded = true
        return treeNode
    }
    
    /// 初始化一个叶子类型
    static func leaf()->JZTreeNode {
        let treeNode =  JZTreeNode()
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
    
    
    /// 计算层级的深度（包括不展开的部分）
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





// 默认类型
class JZTreeCollectionViewCell: UICollectionViewCell {
    
    static let rid = "JZTreeCollectionViewCell"
    
    let containerView: UIView = UIView()
    
    let label = UILabel()
    
    let imageView: UIImageView = UIImageView()
    
    var leftInset: CGFloat = 10.0
    
    lazy fileprivate var indentContraint: NSLayoutConstraint = {
        return self.containerView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: self.leftInset)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderColor = UIColor.purple.cgColor
        self.layer.borderWidth = 1
        
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        indentContraint.isActive = true
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        containerView.addSubview(label)
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if let innerTreeNode = innerTreeNode {
                self.update(treeNode: innerTreeNode)
            }
        }
    }
    override var isSelected: Bool {
        didSet {
            if let innerTreeNode = innerTreeNode {
                self.update(treeNode: innerTreeNode)
            }
        }
    }
    
    
    private var innerTreeNode: JZTreeNode? = nil
    
    /// 刷新
    public func update(treeNode: JZTreeNode) {
        innerTreeNode = treeNode
        // 更新
        label.text = "level: \(treeNode.level) isNode: \(treeNode.isNode)"
        
        // 更具内容更新inset
        self.leftInset = 10.0 + CGFloat(treeNode.level) * 25.0
        self.indentContraint.constant = self.leftInset
        
        let highlighted = (self.isHighlighted || self.isSelected)
        
        if treeNode.isNode == true {
            let image = UIImage(systemName: "chevron.right.circle.fill")
            self.imageView.image = image
            if treeNode.isExpanded == true {
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            } else {
                self.imageView.transform = CGAffineTransform.identity
            }
        } else {
            let image = UIImage(systemName: "circle.fill")
            self.imageView.image = image
        }
        
        // 颜色修改
        self.imageView.tintColor = highlighted ? .gray : UIColor(displayP3Red: 100.0 / 255.0, green: 149.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
}



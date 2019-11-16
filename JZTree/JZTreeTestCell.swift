//
//  JZTreeTestCell.swift
//  JZTree
//
//  Created by wizet on 2019/11/16.
//  Copyright © 2019 wizet. All rights reserved.
//

import UIKit


// 默认类型
class JZTreeTestCell: UICollectionViewCell {
    
    // 长按手势
    var longPressGestureClosure: (() -> Void)? = nil
    
    static let rid = "JZTreeTestCell"
    
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
        
        
        addLPG()
    }
    
    private func addLPG() {
        self.contentView.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(LPGAction(sender:))))
    }
    
    @objc private func LPGAction(sender: UILongPressGestureRecognizer) {
        longPressGestureClosure?()
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



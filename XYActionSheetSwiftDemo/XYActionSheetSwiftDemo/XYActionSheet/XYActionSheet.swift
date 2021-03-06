//
//  XYActionSheet.swift
//  XYActionSheetSwiftDemo
//
//  Created by FireHsia on 2017/9/8.
//  Copyright © 2017年 FireHsia. All rights reserved.
//


import UIKit

typealias XYActionSheetClosureType = (NSInteger) -> Void

private let k_XYWidth : CGFloat = UIScreen.main.bounds.size.width
private let k_XYHeight : CGFloat = UIScreen.main.bounds.size.height
private let k_XYWindow = UIApplication.shared.keyWindow!
private let kSheetCellHeight : CGFloat = 50
private let kSheetFooterHeight : CGFloat = 5
private let kXYActionSheetCell = "kXYActionSheetCell_Identifier"

class XYActionSheet: NSObject {
    
    open static var actionSheetManager : XYActionSheet? = nil
    
    fileprivate var actionSheetClosure : XYActionSheetClosureType? = nil
    
    override init() {
        super.init()
    }
    
    open class func actionSheet() -> XYActionSheet! {
        if actionSheetManager == nil {
            actionSheetManager = XYActionSheet.init()
        }
        return actionSheetManager!
    }
    
    public func showActionSheetWithTitles(_ titles : [String]!, _ closure : XYActionSheetClosureType!) -> Void {
        
        actionSheetClosure = closure
        dataArray = titles
        bgView.addSubview(listView)
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.bgView.backgroundColor = UIColor(white: 0.1, alpha: 0.2)
            k_XYWindow.addSubview(self.bgView)
            self.listView.frame = CGRect(x: 0, y: k_XYHeight - CGFloat((CGFloat(self.dataArray!.count + 1) * kSheetCellHeight) + kSheetFooterHeight), width: k_XYWidth, height: (CGFloat(self.dataArray!.count + 1) * kSheetCellHeight) + kSheetFooterHeight);
        }
    }
    
    @objc fileprivate func closeSheet(tap : UITapGestureRecognizer?) {
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            
            self.bgView.backgroundColor = UIColor(white: 0, alpha: 0)
            self.listView.frame = CGRect(x: 0, y: k_XYHeight, width: k_XYWidth, height: (CGFloat(self.dataArray!.count + 1) * kSheetCellHeight) + kSheetFooterHeight)
        }) { (complete) in
            self.bgView.removeFromSuperview()
            XYActionSheet.actionSheetManager = nil;
        }
    }
    
    
    // MARK : LazyLoad
    lazy var bgView : UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: k_XYWidth, height: k_XYHeight)
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeSheet))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var listView : UITableView  = {
        var tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.frame = CGRect(x: 0, y: k_XYHeight, width: k_XYWidth, height: ((CGFloat(self.dataArray!.count + 1) * kSheetCellHeight) + kSheetFooterHeight))
        tableView.isScrollEnabled = false
        tableView.rowHeight = kSheetCellHeight
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: kXYActionSheetCell)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var dataArray : [String]? = {
        var array : [String]? = nil;
        return array
    }()
    
}

extension XYActionSheet : UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    // MARK : UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var actionSheetView = touch.view
        while actionSheetView?.superview?.isKind(of: UIView.classForCoder()) != nil {
            if (actionSheetView?.isKind(of: UITableView.classForCoder()))! || (actionSheetView?.isKind(of: UITableViewCell.classForCoder()))! {
                return false
            }
            actionSheetView = actionSheetView?.superview
        }
        return true
    }
    
    // MARK: TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return dataArray!.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: k_XYWidth, height: kSheetCellHeight))
            view.backgroundColor = UIColor(white: 0.9, alpha: 1)
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return kSheetFooterHeight
        }
        return 0
    }
    
    //  菜单样式可以通过Cell自定义
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kXYActionSheetCell, for: indexPath)
        let selectedBackView = UIView()
        selectedBackView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        cell.selectedBackgroundView = selectedBackView
        if indexPath.section == 1 {
            setTableViewCell(cell: cell, text: "取消")
        }else {
            setTableViewCell(cell: cell, text: dataArray![indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if actionSheetClosure != nil {
            if indexPath.section == 1 {
                actionSheetClosure!(dataArray!.count)
            }else {
                actionSheetClosure!(indexPath.row)
            }
        }
        self.closeSheet(tap: nil)
    }
    
    // MARK : SetTableViewCellTextLabel
    fileprivate func setTableViewCell(cell : UITableViewCell, text : String) {
        cell.textLabel?.backgroundColor = .white
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = text
        cell.textLabel?.bounds = CGRect(x: 0, y: 0, width: k_XYWidth, height: kSheetCellHeight)
    }
    
}

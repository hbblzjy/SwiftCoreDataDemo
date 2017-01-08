//
//  ViewController.swift
//  SwiftCoreDataDemo
//
//  Created by healthmanage on 17/1/6.
//  Copyright © 2017年 healthmanager. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var myTableView = UITableView()
    var dataArray = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "CoreData首页"
        self.view.backgroundColor = UIColor.white
        
        myTableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-50), style: .plain)
        myTableView.delegate = self
        myTableView.dataSource = self
        self.view.addSubview(myTableView)
        
        let oneBtn = UIButton.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height-50, width: UIScreen.main.bounds.size.width/2, height: 50))
        oneBtn.setTitle("增加", for: .normal)
        oneBtn.setTitleColor(UIColor.blue, for: .normal)
        oneBtn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        self.view.addSubview(oneBtn)
        
        let oneBtn1 = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height-50, width: UIScreen.main.bounds.size.width/2, height: 50))
        oneBtn1.setTitle("查询", for: .normal)
        oneBtn1.setTitleColor(UIColor.blue, for: .normal)
        oneBtn1.addTarget(self, action: #selector(btn1Click(btn:)), for: .touchUpInside)
        self.view.addSubview(oneBtn1)
        
    }
    //增加按钮
    func btnClick(btn:UIButton) {
        //print("点击的是增加按钮......")
        self.showAlertView()
    }
    //弹出框
    func showAlertView() {
        let alertCon = UIAlertController.init(title: "改变数据", message: "", preferredStyle: .alert)
        
        alertCon.addTextField { (textF) in
            textF.placeholder = "请输入数据...."
        }
        
        let okAction = UIAlertAction.init(title: "确定", style: .default) { (oneAction) in
            let oneTextF = alertCon.textFields?[0]
            //print("输出输入的内容...\(oneTextF?.text)")
            
            self.saveData(textStr: (oneTextF?.text)!)
            self.myTableView.reloadData()
            
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)
        alertCon.addAction(okAction)
        alertCon.addAction(cancelAction)
        
        self.present(alertCon, animated: true, completion: nil)
    }
    //增加数据
    func saveData(textStr:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext
        let entityOne = NSEntityDescription.entity(forEntityName: "OneOneEntity", in: manageContext)
        let itemS = NSManagedObject.init(entity: entityOne!, insertInto: manageContext)
        itemS.setValue(textStr, forKey: "textStr")
        do {
            try manageContext.save()
            self.dataArray.append(itemS)
            //print("..........\(itemS)")
        } catch  {
            print("存储错误...")
        }
    }
    //删除
    func deleteData(aIndexPath:IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext
        
        manageContext.delete(self.dataArray[aIndexPath.row])
        
        do {
            try manageContext.save()
            self.dataArray.remove(at: aIndexPath.row)
            self.myTableView.reloadData()
        } catch  {
            print("存储错误...")
        }
    }
    //修改
    func updateData(aIndxPath:IndexPath,upStr:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext
        //let entityOne = NSEntityDescription.entity(forEntityName: "OneOneEntity", in: manageContext)
        //创建查询请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OneOneEntity")
        //获取数据
        do {
            let results = try manageContext.fetch(fetchRequest)
            //找到修改的数据
            let oneObj:NSManagedObject = results[aIndxPath.row] as! NSManagedObject
            oneObj.setValue(upStr, forKey: "textStr")
            do {
                try manageContext.save()
                do {
                    let results1 = try manageContext.fetch(fetchRequest)
                    self.dataArray = results1 as! [NSManagedObject]
                    self.myTableView.reloadData()
                } catch  {
                    print("查询错误...")
                }
            } catch  {
                print("存储错误...")
            }
            
        } catch  {
            print("修改错误...")
        }
    }
    //查询
    func lookUpData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext
        
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "OneOneEntity")
        do {
            let results = try manageContext.fetch(fetchReq)
            self.dataArray = results as! [NSManagedObject]
            self.myTableView.reloadData()
        } catch  {
            print("查询错误...")
        }
    }
    //查询按钮
    func btn1Click(btn:UIButton) {
        self.lookUpData()
    }
    //MARK:------UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell0")
        if cell==nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell0")
        }
        cell?.selectionStyle = .none
        
        let oneItem = self.dataArray[indexPath.row]
        cell?.textLabel?.text = oneItem.value(forKey: "textStr") as? String
        
        return cell!
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction.init(style: .normal, title: "删除") { (oneAction, aIndexPath) in
            self.deleteData(aIndexPath: indexPath)
        }
        
        deleteRowAction.backgroundColor = UIColor.red
        return [deleteRowAction]
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let oneItem = self.dataArray[indexPath.row]
        let strT = oneItem.value(forKey: "textStr") as? String
        
        
        let alertCon = UIAlertController.init(title: "改变数据", message: "", preferredStyle: .alert)
        
        alertCon.addTextField { (textF) in
            textF.text = strT
        }
        
        let okAction = UIAlertAction.init(title: "确定", style: .default) { (oneAction) in
            let oneTextF = alertCon.textFields?[0]
            //print("输出输入的内容...\(oneTextF?.text)")
            
            self.updateData(aIndxPath: indexPath, upStr: (oneTextF?.text)!)
            
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)
        alertCon.addAction(okAction)
        alertCon.addAction(cancelAction)
        
        self.present(alertCon, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


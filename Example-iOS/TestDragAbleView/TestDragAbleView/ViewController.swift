//
//  ViewController.swift
//  TestDragAbleView
//
//  Created by 박길호(팀원) - D/I개발담당App개발팀 on 6/16/26.
//

import UIKit
import DragAbleView

class ViewController: UIViewController {
    var dragAbleViewManager: DragAbleViewManager?
    var blueBoxView: DragAbleView!
    var itemViews = [UIView]()

    var addButton: UIButton!
    var removeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "DragAbleView"

        let top = self.view.safeAreaInsets.top

        addButton = UIButton(frame: CGRect(x: 50, y: top + 150, width: 50, height: 50))
        addButton?.setTitle("add", for: .normal)
        addButton?.addTarget(self, action: #selector(self.onButtonAdd), for: .touchUpInside)
        addButton?.backgroundColor = .blue
        self.view.addSubview(addButton)

        removeButton = UIButton(frame: CGRect(x: 150, y: top + 150, width: 80, height: 50))
        removeButton?.setTitle("remove", for: .normal)
        removeButton?.addTarget(self, action: #selector(self.onButtonRemove), for: .touchUpInside)
        removeButton?.backgroundColor = .red
        self.view.addSubview(removeButton)
    }

//    deinit {
//        for view in itemViews {
//            view.removeFromSuperview()
//        }
//    }

    @objc func onButtonAdd() {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        let top = window.safeAreaInsets.top
        let bottom = window.safeAreaInsets.bottom
        let v = TestView(frame: CGRect(x: 100, y: top + 100, width: 100, height: 100))
        v.backgroundColor = UIColor.random

        itemViews.append(v)
        if dragAbleViewManager == nil {
            dragAbleViewManager = DragAbleViewManager(containerView: window, setBoundsIntoBoundary: UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0), itemViews: [v])
        }
        else {
            dragAbleViewManager?.addView(view: v)
        }
    }

    @objc func onButtonRemove() {
        if let v = itemViews.last {
            dragAbleViewManager?.removeView(view: v)
            v.removeFromSuperview()
            itemViews.removeLast()
        }
    }
}


class TestView: UIView {
    deinit {
        print("\(#function) TestView")
    }
}

extension UIColor {
    ///   Returns random UIColor with random alpha(default: false)
    static var random: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

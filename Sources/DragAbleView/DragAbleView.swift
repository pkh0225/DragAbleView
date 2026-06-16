// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

@MainActor
public class DragAbleView: UIView {
    weak var containerView: UIView?
    // 다이나믹스 애니메이터 인스턴스 변수 선언
    public var animator: UIDynamicAnimator?
    // 탄성 설정
    public var viewBehavior: UIDynamicItemBehavior?
    // 항목이 붙어있는 것을 구현할 수 있는 클래스
    public var attachment: UIAttachmentBehavior?
    // 충돌 설정
    public var collision: UICollisionBehavior?
    // 앵커 포인트 현재 위치 저장할 변수
    var currentLocation: CGPoint = .zero

    /// View가 먼저 Add 된 후 호출 해야 함
    /// - Parameters:
    ///   - containerView: 경계가 되는 부모 뷰
    ///   - setBoundsIntoBoundary: insets
    public func setContainerView(containerView: UIView, setBoundsIntoBoundary: UIEdgeInsets) {
        self.containerView = containerView
        animator = UIDynamicAnimator(referenceView: containerView)

        viewBehavior = UIDynamicItemBehavior(items: [self])
        viewBehavior?.allowsRotation = false
        viewBehavior?.resistance = 5
        viewBehavior?.density = 0.02
        animator?.addBehavior(viewBehavior!)

        collision = UICollisionBehavior(items: [self])
        collision?.translatesReferenceBoundsIntoBoundary = true
        collision?.setTranslatesReferenceBoundsIntoBoundary(with: setBoundsIntoBoundary)
        animator?.addBehavior(collision!)

        addPanGesture()
    }

    /// 저항 조절
    /// - Parameter value: 커질수록 속도가 빨리 줄어듬
    public func setResistance(_ value: CGFloat) {
        viewBehavior?.resistance = value
    }

    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let containerView = self.containerView else { return }
        switch gesture.state {
        case .began:
            containerView.bringSubviewToFront(self)
            currentLocation = gesture.location(in: containerView)
            attachment = UIAttachmentBehavior(item: self, attachedToAnchor: currentLocation)
            animator?.addBehavior(attachment!)
        case .changed:
            currentLocation = gesture.location(in: containerView)
            attachment?.anchorPoint = currentLocation
        case .cancelled, .ended:
            let velocity = gesture.velocity(in: containerView)
            viewBehavior?.addLinearVelocity(velocity, for: self)
            if let attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        case .failed:
            if let attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        case .possible:
            break
        @unknown default:
            break
        }
    }
}

@MainActor
public class DragAbleViewManager {
    public weak var containerView: UIView?
    public var itemViews = [UIView: UIPanGestureRecognizer]()
    // 다이나믹스 애니메이터 인스턴스 변수 선언
    var animator: UIDynamicAnimator?
    // 탄성 설정
    var viewBehavior: UIDynamicItemBehavior?
    // 항목이 붙어있는 것을 구현할 수 있는 클래스
    var attachment: UIAttachmentBehavior?
    // 충돌 설정
    var collision: UICollisionBehavior?
    // 앵커 포인트 현재 위치 저장할 변수
    var currentLocation: CGPoint = .zero

    // View가 먼저 Add 된 후 호출 해야 함
    public init(containerView: UIView, setBoundsIntoBoundary: UIEdgeInsets, itemViews: [UIView]) {
        itemViews.forEach {
            $0.tagName = "DragAbleView"
            containerView.addSubview( $0 )
        }
        self.containerView = containerView
        animator = UIDynamicAnimator(referenceView: containerView)

        viewBehavior = UIDynamicItemBehavior(items: itemViews)
        viewBehavior?.allowsRotation = false
        viewBehavior?.resistance = 5
        viewBehavior?.density = 0.02
        animator?.addBehavior(viewBehavior!)

        collision = UICollisionBehavior(items: itemViews)
        collision?.translatesReferenceBoundsIntoBoundary = true
        collision?.setTranslatesReferenceBoundsIntoBoundary(with: setBoundsIntoBoundary)
        animator?.addBehavior(collision!)

        addPanGesture(itemViews: itemViews)
    }

    public func getView(tag: Int) -> UIView? {
        self.itemViews.filter { $0.key.tag == tag }.first?.key
    }

    public func addView(view: UIView) {
        view.tagName = "DragAbleView"
        self.containerView?.addSubview( view )
        viewBehavior?.addItem(view)
        collision?.addItem(view)
        addPanGesture(itemViews: [view])
    }

    public func removeView(view: UIView) {
        viewBehavior?.removeItem(view)
        collision?.removeItem(view)
        if let g = self.itemViews[view] {
            view.removeGestureRecognizer(g)
        }
        self.itemViews.removeValue(forKey: view)
        view.removeFromSuperview()
    }

    public func removeView(tag: Int) {
        guard let view = self.getView(tag: tag) else { return }
        removeView(view: view)
    }

    private func addPanGesture(itemViews: [UIView]) {
        for v in itemViews {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            v.addGestureRecognizer(panGesture)
            self.itemViews[v] = panGesture
        }
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view  else { return }
        guard let containerView = self.containerView else { return }
        switch gesture.state {
        case .began:
            containerView.bringSubviewToFront(view)
            currentLocation = gesture.location(in: containerView)
            attachment = UIAttachmentBehavior(item: view, attachedToAnchor: currentLocation)
            animator?.addBehavior(attachment!)
        case .changed:
            currentLocation = gesture.location(in: containerView)
            attachment?.anchorPoint = currentLocation
        case .cancelled, .ended:
            let velocity = gesture.velocity(in: containerView)
            viewBehavior?.addLinearVelocity(velocity, for: view)
            if let attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        case .possible:
            break
        case .failed:
            if let attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        @unknown default:
            break
        }
    }
}

nonisolated private extension UIView {
    private struct AssociatedKeys {
        nonisolated(unsafe) static var tagName: UInt8 = 0
    }

    var tagName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tagName) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tagName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

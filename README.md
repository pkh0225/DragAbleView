# DragAbleView

UIKit Dynamics 기반으로 뷰를 자연스럽게 드래그할 수 있게 해주는 iOS 라이브러리입니다.  
손가락을 떼면 관성(inertia)이 적용되고, 컨테이너 경계에서 충돌 처리됩니다.

## 특징

- **물리 기반 드래그** — `UIDynamicAnimator`, `UIAttachmentBehavior`, `UIDynamicItemBehavior`를 활용한 자연스러운 이동
- **경계 충돌** — 컨테이너 뷰의 safe area 등을 반영한 경계(inset) 설정 지원
- **관성 유지** — 드래그 종료 시 손가락 속도(velocity)가 그대로 전달되어 관성 이동
- **단일 / 다중 뷰** — `DragAbleView` 서브클래스 또는 `DragAbleViewManager`로 여러 뷰를 일괄 관리
- **동적 추가·제거** — 런타임에 드래그 가능한 뷰를 추가하거나 제거 가능

## 요구 사항

| 항목 | 버전 |
|------|------|
| iOS | 14.0+ |
| Swift | 5.5+ |
| Xcode | 13.0+ |

## 설치

### Swift Package Manager

Xcode에서 **File → Add Package Dependencies** 를 선택한 뒤 저장소 URL을 입력합니다.

```
https://github.com/pkh0225/DragAbleView
```

또는 `Package.swift`에 직접 추가합니다.

```swift
dependencies: [
    .package(url: "https://github.com/pkh0225/DragAbleView", from: "0.1.0")
]
```

## 사용법

### 1. 단일 뷰 — `DragAbleView`

`DragAbleView`는 `UIView`를 상속합니다. 컨테이너에 추가한 뒤 `setContainerView`를 호출해야 드래그가 활성화됩니다.

```swift
import UIKit
import DragAbleView

let containerView = view  // 경계가 될 부모 뷰
let draggable = DragAbleView(frame: CGRect(x: 100, y: 200, width: 120, height: 120))
draggable.backgroundColor = .systemBlue

containerView.addSubview(draggable)

// safe area inset을 경계로 사용
let insets = view.safeAreaInsets
draggable.setContainerView(
    containerView: containerView,
    setBoundsIntoBoundary: UIEdgeInsets(
        top: insets.top,
        left: 0,
        bottom: insets.bottom,
        right: 0
    )
)

// (선택) 저항값 조절 — 값이 클수록 속도가 빨리 줄어듦 (기본값: 5)
draggable.setResistance(8)
```

### 2. 다중 뷰 — `DragAbleViewManager`

여러 `UIView`를 한 번에 드래그 가능하게 만들 때 사용합니다. 초기화 시 뷰를 컨테이너에 자동으로 추가합니다.

```swift
import UIKit
import DragAbleView

let box1 = UIView(frame: CGRect(x: 50, y: 150, width: 80, height: 80))
box1.backgroundColor = .systemRed
box1.tag = 1

let box2 = UIView(frame: CGRect(x: 200, y: 150, width: 80, height: 80))
box2.backgroundColor = .systemGreen
box2.tag = 2

let manager = DragAbleViewManager(
    containerView: window,
    setBoundsIntoBoundary: UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0),
    itemViews: [box1, box2]
)

// 런타임에 뷰 추가
let box3 = UIView(frame: CGRect(x: 100, y: 300, width: 80, height: 80))
manager.addView(view: box3)

// tag로 뷰 조회 후 제거
manager.removeView(tag: 1)

// UIView 참조로 제거
manager.removeView(view: box2)
```

## API 요약

### `DragAbleView`

| 멤버 | 설명 |
|------|------|
| `setContainerView(containerView:setBoundsIntoBoundary:)` | 컨테이너와 경계 inset을 설정하고 드래그 제스처를 등록합니다. **뷰를 addSubview한 뒤 호출해야 합니다.** |
| `setResistance(_:)` | `UIDynamicItemBehavior.resistance` 값을 변경합니다. 기본값 `5`. |
| `animator` | 내부 `UIDynamicAnimator` 인스턴스 (고급 커스터마이징용) |
| `viewBehavior` | 내부 `UIDynamicItemBehavior` 인스턴스 |
| `collision` | 내부 `UICollisionBehavior` 인스턴스 |

### `DragAbleViewManager`

| 멤버 | 설명 |
|------|------|
| `init(containerView:setBoundsIntoBoundary:itemViews:)` | 컨테이너, 경계 inset, 초기 뷰 목록으로 매니저를 생성합니다. |
| `addView(view:)` | 드래그 가능한 뷰를 동적으로 추가합니다. |
| `removeView(view:)` | 뷰를 제거하고 물리 시뮬레이션에서도 해제합니다. |
| `removeView(tag:)` | `tag`로 뷰를 찾아 제거합니다. |
| `getView(tag:)` | `tag`에 해당하는 뷰를 반환합니다. |

## 동작 원리

```
드래그 시작 (.began)
  └─ UIAttachmentBehavior로 터치 위치에 뷰를 고정
드래그 중 (.changed)
  └─ anchorPoint를 터치 위치로 갱신
드래그 종료 (.ended / .cancelled)
  └─ attachment 제거 + velocity를 UIDynamicItemBehavior에 전달 → 관성 이동
  └─ UICollisionBehavior가 컨테이너 경계(inset)에서 뷰를 멈춤
```

기본 물리 파라미터:

| 파라미터 | 기본값 | 설명 |
|----------|--------|------|
| `allowsRotation` | `false` | 회전 비활성화 |
| `resistance` | `5` | 공기 저항 (클수록 빨리 감속) |
| `density` | `0.02` | 밀도 |

## 예제 앱

`Example-iOS/TestDragAbleView` 에 iOS 예제 프로젝트가 포함되어 있습니다.

- **add** 버튼: 랜덤 색상의 뷰를 윈도우에 추가하고 `DragAbleViewManager`로 드래그 활성화
- **remove** 버튼: 마지막으로 추가한 뷰를 제거

Xcode에서 `Example-iOS/TestDragAbleView/TestDragAbleView.xcodeproj` 를 열어 실행할 수 있습니다.

## 라이선스

[MIT License](LICENSE) — Copyright (c) 2026 박길호

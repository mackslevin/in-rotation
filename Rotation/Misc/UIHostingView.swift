


import Foundation
import SwiftUI


// This class allows to write the action extension's UI in SwiftUI rather than UIKit. See ActionViewController.viewDidLoad.
final class UIHostingView<Content: View>: UIView {
    private let rootViewHostingController: UIHostingController<Content>

    var rootView: Content {
        get { rootViewHostingController.rootView }
        set {
            rootViewHostingController.rootView = newValue
        }
    }

    required init(rootView: Content) {
        self.rootViewHostingController = UIHostingController(rootView: rootView)
        super.init(frame: .zero)
        rootViewHostingController.view.backgroundColor = .clear
        addSubview(rootViewHostingController.view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rootViewHostingController.view.frame = bounds
    }

    override func sizeToFit() {
        guard let superview else {
            super.sizeToFit()
            return
        }

        frame.size = rootViewHostingController.sizeThatFits(in: superview.frame.size)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: size)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }
}

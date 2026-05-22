//
//  GlassCard.swift
//  SamplecoreBluethooth
//
//  Create by Esakki IOS 20 may 2026
//

import UIKit

final class GlassCard: UIView {

    private let innerStack = UIStackView()

    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18) {
        didSet { innerStack.layoutMargins = contentInsets }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setup() {
        backgroundColor        = .nsCard
        layer.cornerRadius     = 22
        layer.borderWidth      = 1
        layer.borderColor      = UIColor.nsBorder.cgColor
        layer.masksToBounds    = true

        innerStack.axis                                  = .vertical
        innerStack.spacing                               = 12
        innerStack.layoutMargins                         = contentInsets
        innerStack.isLayoutMarginsRelativeArrangement   = true
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerStack)

        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: topAnchor),
            innerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func addContent(_ view: UIView) {
        innerStack.addArrangedSubview(view)
    }
}

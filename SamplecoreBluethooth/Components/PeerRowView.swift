//
//  PeerRowView.swift
//  SamplecoreBluethooth
//
//  Create by Esakki IOS 20 may 2026
//

import UIKit
import MultipeerConnectivity

final class PeerRowView: UIView {

    var onTap: (() -> Void)?

    private let avatarBg    = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel   = UILabel()
    private let stateLabel  = UILabel()
    private let stateDot    = UIView()
    private let checkIcon   = UIImageView()

    init(peer: NearPeer, isSelected: Bool) {
        super.init(frame: .zero)
        build(peer: peer, isSelected: isSelected)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build(peer: NearPeer, isSelected: Bool) {
        heightAnchor.constraint(equalToConstant: 70).isActive = true

        avatarBg.layer.cornerRadius = 24
        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarBg)

        avatarLabel.text          = String(peer.peerID.displayName.prefix(1)).uppercased()
        avatarLabel.font          = UIFont.systemFont(ofSize: 20, weight: .bold)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.addSubview(avatarLabel)

        stateDot.layer.cornerRadius = 5
        stateDot.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stateDot)

        nameLabel.text      = peer.peerID.displayName
        nameLabel.font      = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .nsTextPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)

        stateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stateLabel)

        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        checkIcon.image    = UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg)
        checkIcon.tintColor = .nsAccent
        checkIcon.isHidden = !isSelected
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(checkIcon)

        applyStyle(for: peer.connectionState)

        NSLayoutConstraint.activate([
            avatarBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            avatarBg.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarBg.widthAnchor.constraint(equalToConstant: 48),
            avatarBg.heightAnchor.constraint(equalToConstant: 48),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor),

            stateDot.centerYAnchor.constraint(equalTo: centerYAnchor),
            stateDot.leadingAnchor.constraint(equalTo: avatarBg.trailingAnchor, constant: 12),
            stateDot.widthAnchor.constraint(equalToConstant: 10),
            stateDot.heightAnchor.constraint(equalToConstant: 10),

            nameLabel.leadingAnchor.constraint(equalTo: stateDot.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: -17),
            nameLabel.trailingAnchor.constraint(equalTo: checkIcon.leadingAnchor, constant: -8),

            stateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            stateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),

            checkIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            checkIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkIcon.widthAnchor.constraint(equalToConstant: 22),
            checkIcon.heightAnchor.constraint(equalToConstant: 22)
        ])

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    private func applyStyle(for state: PeerConnectionState) {
        switch state {
        case .connected:
            avatarBg.backgroundColor = .nsGreenDim
            avatarLabel.textColor    = .nsGreen
            stateDot.backgroundColor = .nsGreen
            stateLabel.text          = "Connected ✓"
            stateLabel.textColor     = .nsGreen

        case .connecting:
            avatarBg.backgroundColor = .nsYellowDim
            avatarLabel.textColor    = .nsYellow
            stateDot.backgroundColor = .nsYellow
            stateLabel.text          = "Connecting..."
            stateLabel.textColor     = .nsYellow

        case .discovered:
            avatarBg.backgroundColor = .nsAccentDim
            avatarLabel.textColor    = .nsAccent
            stateDot.backgroundColor = .nsTextTer
            stateLabel.text          = "Discovered"
            stateLabel.textColor     = .nsTextTer

        case .disconnected:
            avatarBg.backgroundColor = .nsRedDim
            avatarLabel.textColor    = .nsRed
            stateDot.backgroundColor = .nsRed
            stateLabel.text          = "Disconnected"
            stateLabel.textColor     = .nsRed
        }
    }

    @objc private func handleTap() {
        UIView.animate(withDuration: 0.08, animations: { self.alpha = 0.45 }) { _ in
            UIView.animate(withDuration: 0.12) { self.alpha = 1 }
        }
        onTap?()
    }
}

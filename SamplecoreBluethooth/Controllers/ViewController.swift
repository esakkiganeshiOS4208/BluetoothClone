//
//  ViewController.swift
//  SamplecoreBluethooth
//
//  Create by Esakki IOS 20 may 2026
//

import UIKit
import MultipeerConnectivity
import UniformTypeIdentifiers

final class ViewController: UIViewController {

    private let multipeer    = MultipeerManager()
    private var peers: [NearPeer] = []
    private var selectedPeerID: MCPeerID? { didSet { rebuildPeerRows() } }
    private var isSendingFile = false

    private let scrollView   = UIScrollView()
    private let pageStack    = UIStackView()

    private let headerCard   = GlassCard()
    private let pulseRing    = UIView()
    private let waveIcon     = UIImageView()
    private let appTitleLbl  = UILabel()
    private let appSubLbl    = UILabel()

    private let statusStrip  = UIView()
    private let statusDot    = UIView()
    private let statusLabel  = UILabel()
    private let deviceLabel  = UILabel()

    private let peersCard     = GlassCard()
    private let peersHeader   = UIView()
    private let peersTitleLbl = UILabel()
    private let peersBadge    = UILabel()
    private let peersStack    = UIStackView()
    private let emptyView     = EmptyStateView()

    private let transferCard     = GlassCard()
    private let transferProgress = TransferProgressView()

    private let logCard      = GlassCard()
    private let logHeader    = UIView()
    private let logTitleLbl  = UILabel()
    private let clearBtn     = UIButton(type: .system)
    private let logTextView  = UITextView()

    private let sendButton   = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        buildGradient()
        buildLayout()
        multipeer.delegate = self
        multipeer.start()
        syncUI()
    }

    private func buildGradient() {
        let g        = CAGradientLayer()
        g.frame      = UIScreen.main.bounds
        g.colors     = [
            UIColor(red: 0.04, green: 0.04, blue: 0.16, alpha: 1).cgColor,
            UIColor(red: 0.07, green: 0.04, blue: 0.22, alpha: 1).cgColor,
            UIColor(red: 0.03, green: 0.09, blue: 0.19, alpha: 1).cgColor
        ]
        g.locations  = [0, 0.5, 1]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(g, at: 0)
    }

    private func buildLayout() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageStack.axis       = .vertical
        pageStack.spacing    = 14
        pageStack.layoutMargins = UIEdgeInsets(top: 22, left: 18, bottom: 34, right: 18)
        pageStack.isLayoutMarginsRelativeArrangement = true
        pageStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(pageStack)
        NSLayoutConstraint.activate([
            pageStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            pageStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            pageStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            pageStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            pageStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        buildHeader()
        buildStatusStrip()
        buildPeersCard()
        buildTransferCard()
        buildLogCard()
        buildSendButton()
    }

    private func buildHeader() {
        pulseRing.backgroundColor    = .nsAccentDim
        pulseRing.layer.cornerRadius = 40
        pulseRing.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        waveIcon.image       = UIImage(systemName: "dot.radiowaves.left.and.right", withConfiguration: cfg)
        waveIcon.tintColor   = .nsAccent
        waveIcon.contentMode = .scaleAspectFit
        waveIcon.translatesAutoresizingMaskIntoConstraints = false

        appTitleLbl.text      = "NearShare"
        appTitleLbl.font      = UIFont.systemFont(ofSize: 28, weight: .bold)
        appTitleLbl.textColor = .nsTextPrimary

        appSubLbl.text      = "Bluetooth · Wi-Fi · P2P File Sharing"
        appSubLbl.font      = UIFont.systemFont(ofSize: 13, weight: .regular)
        appSubLbl.textColor = .nsTextSec

        let textStack = UIStackView(arrangedSubviews: [appTitleLbl, appSubLbl])
        textStack.axis    = .vertical
        textStack.spacing = 4

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 84).isActive = true
        container.addSubview(pulseRing)
        container.addSubview(waveIcon)

        textStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            pulseRing.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
            pulseRing.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pulseRing.widthAnchor.constraint(equalToConstant: 80),
            pulseRing.heightAnchor.constraint(equalToConstant: 80),

            waveIcon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            waveIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            waveIcon.widthAnchor.constraint(equalToConstant: 44),
            waveIcon.heightAnchor.constraint(equalToConstant: 44),

            textStack.leadingAnchor.constraint(equalTo: waveIcon.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        headerCard.addContent(container)
        pageStack.addArrangedSubview(headerCard)

        UIView.animate(withDuration: 1.8, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.waveIcon.alpha = 0.5
        }
        UIView.animate(withDuration: 2.2, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.pulseRing.transform = CGAffineTransform(scaleX: 1.20, y: 1.20)
            self.pulseRing.alpha     = 0.25
        }
    }

    private func buildStatusStrip() {
        statusStrip.backgroundColor    = .nsCard
        statusStrip.layer.cornerRadius = 16
        statusStrip.layer.borderWidth  = 1
        statusStrip.layer.borderColor  = UIColor.nsBorder.cgColor
        statusStrip.translatesAutoresizingMaskIntoConstraints = false
        statusStrip.heightAnchor.constraint(equalToConstant: 42).isActive = true

        statusDot.backgroundColor    = .nsGreen
        statusDot.layer.cornerRadius = 5.5
        statusDot.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.text      = "Scanning..."
        statusLabel.font      = UIFont.systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = .nsTextPrimary
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        deviceLabel.text          = UIDevice.current.name
        deviceLabel.font          = UIFont.systemFont(ofSize: 12, weight: .regular)
        deviceLabel.textColor     = .nsTextTer
        deviceLabel.textAlignment = .right
        deviceLabel.translatesAutoresizingMaskIntoConstraints = false

        statusStrip.addSubview(statusDot)
        statusStrip.addSubview(statusLabel)
        statusStrip.addSubview(deviceLabel)

        NSLayoutConstraint.activate([
            statusDot.leadingAnchor.constraint(equalTo: statusStrip.leadingAnchor, constant: 16),
            statusDot.centerYAnchor.constraint(equalTo: statusStrip.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 11),
            statusDot.heightAnchor.constraint(equalToConstant: 11),

            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 9),
            statusLabel.centerYAnchor.constraint(equalTo: statusStrip.centerYAnchor),

            deviceLabel.trailingAnchor.constraint(equalTo: statusStrip.trailingAnchor, constant: -16),
            deviceLabel.centerYAnchor.constraint(equalTo: statusStrip.centerYAnchor),
            deviceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: statusLabel.trailingAnchor, constant: 8)
        ])

        pageStack.addArrangedSubview(statusStrip)

        UIView.animate(withDuration: 0.9, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.statusDot.alpha = 0.3
        }
    }

    private func buildPeersCard() {
        peersHeader.translatesAutoresizingMaskIntoConstraints = false
        peersHeader.heightAnchor.constraint(equalToConstant: 26).isActive = true

        peersTitleLbl.text      = "Nearby Devices"
        peersTitleLbl.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        peersTitleLbl.textColor = .nsTextPrimary
        peersTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        peersHeader.addSubview(peersTitleLbl)

        peersBadge.font             = UIFont.systemFont(ofSize: 11, weight: .bold)
        peersBadge.textColor        = .nsAccent
        peersBadge.backgroundColor  = .nsAccentDim
        peersBadge.textAlignment    = .center
        peersBadge.layer.cornerRadius = 9
        peersBadge.clipsToBounds    = true
        peersBadge.isHidden         = true
        peersBadge.translatesAutoresizingMaskIntoConstraints = false
        peersHeader.addSubview(peersBadge)

        NSLayoutConstraint.activate([
            peersTitleLbl.leadingAnchor.constraint(equalTo: peersHeader.leadingAnchor),
            peersTitleLbl.centerYAnchor.constraint(equalTo: peersHeader.centerYAnchor),
            peersBadge.leadingAnchor.constraint(equalTo: peersTitleLbl.trailingAnchor, constant: 8),
            peersBadge.centerYAnchor.constraint(equalTo: peersHeader.centerYAnchor),
            peersBadge.heightAnchor.constraint(equalToConstant: 18),
            peersBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])

        peersStack.axis    = .vertical
        peersStack.spacing = 0
        emptyView.translatesAutoresizingMaskIntoConstraints = false

        peersCard.addContent(peersHeader)
        peersCard.addContent(emptyView)
        peersCard.addContent(peersStack)
        pageStack.addArrangedSubview(peersCard)
    }

    private func buildTransferCard() {
        transferProgress.translatesAutoresizingMaskIntoConstraints = false
        transferCard.addContent(transferProgress)
        transferCard.layer.borderColor = UIColor.nsAccentGlow.cgColor
        transferCard.isHidden          = true
        pageStack.addArrangedSubview(transferCard)
    }

    private func buildLogCard() {
        logHeader.translatesAutoresizingMaskIntoConstraints = false
        logHeader.heightAnchor.constraint(equalToConstant: 26).isActive = true

        logTitleLbl.text      = "Activity Log"
        logTitleLbl.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        logTitleLbl.textColor = .nsTextPrimary
        logTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        logHeader.addSubview(logTitleLbl)

        clearBtn.setTitle("Clear", for: .normal)
        clearBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        clearBtn.tintColor        = .nsAccent
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
        logHeader.addSubview(clearBtn)

        NSLayoutConstraint.activate([
            logTitleLbl.leadingAnchor.constraint(equalTo: logHeader.leadingAnchor),
            logTitleLbl.centerYAnchor.constraint(equalTo: logHeader.centerYAnchor),
            clearBtn.trailingAnchor.constraint(equalTo: logHeader.trailingAnchor),
            clearBtn.centerYAnchor.constraint(equalTo: logHeader.centerYAnchor)
        ])

        logTextView.isEditable   = false
        logTextView.backgroundColor = UIColor(white: 0, alpha: 0.28)
        logTextView.layer.cornerRadius = 12
        logTextView.font         = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.textColor    = UIColor(white: 1, alpha: 0.68)
        logTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        logTextView.text         = "── Session started ──"
        logTextView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        logCard.addContent(logHeader)
        logCard.addContent(logTextView)
        pageStack.addArrangedSubview(logCard)
    }

    private func buildSendButton() {
        var cfg = UIButton.Configuration.filled()
        cfg.title               = "Send File"
        cfg.image               = UIImage(systemName: "square.and.arrow.up.fill")
        cfg.imagePadding        = 10
        cfg.cornerStyle         = .fixed
        cfg.background.cornerRadius = 18
        cfg.baseBackgroundColor = .nsAccent
        cfg.baseForegroundColor = .white
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            return a
        }
        sendButton.configuration     = cfg
        sendButton.layer.shadowColor = UIColor.nsAccentGlow.cgColor
        sendButton.layer.shadowOffset  = CGSize(width: 0, height: 6)
        sendButton.layer.shadowRadius  = 14
        sendButton.layer.shadowOpacity = 1.0
        sendButton.heightAnchor.constraint(equalToConstant: 58).isActive = true
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        pageStack.addArrangedSubview(sendButton)
    }

    private func syncUI() {
        let connected  = peers.filter { $0.isConnected }.count
        let discovered = peers.count

        if connected > 0 {
            statusLabel.text          = "\(connected) device\(connected > 1 ? "s" : "") connected"
            statusDot.backgroundColor = .nsGreen
        } else if discovered > 0 {
            statusLabel.text          = "\(discovered) device\(discovered > 1 ? "s" : "") found — connecting..."
            statusDot.backgroundColor = .nsYellow
        } else {
            statusLabel.text          = "Scanning for devices..."
            statusDot.backgroundColor = .nsGreen
        }

        peersBadge.text    = discovered > 0 ? " \(discovered) " : nil
        peersBadge.isHidden = discovered == 0

        let canSend = connected > 0
        UIView.animate(withDuration: 0.25) { self.sendButton.alpha = canSend ? 1.0 : 0.38 }
        sendButton.isEnabled = canSend
    }

    private func rebuildPeerRows() {
        peersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if peers.isEmpty {
            emptyView.isHidden  = false
            peersStack.isHidden = true
        } else {
            emptyView.isHidden  = true
            peersStack.isHidden = false
            for (idx, peer) in peers.enumerated() {
                let row = PeerRowView(peer: peer, isSelected: peer.peerID == selectedPeerID)
                row.onTap = { [weak self] in self?.peerTapped(peer.peerID) }
                peersStack.addArrangedSubview(row)
                if idx < peers.count - 1 {
                    let div = UIView()
                    div.backgroundColor = .nsBorder
                    div.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                    peersStack.addArrangedSubview(div)
                }
            }
        }
        syncUI()
    }

    private func peerTapped(_ peerID: MCPeerID) {
        guard let peer = peers.first(where: { $0.peerID == peerID }) else { return }
        switch peer.connectionState {
        case .connected:
            selectedPeerID = (selectedPeerID == peerID) ? nil : peerID
            log(selectedPeerID == peerID
                ? "✅ Selected \(peerID.displayName) as send target"
                : "⬜ Deselected \(peerID.displayName)")
        case .connecting:
            showAlert("Connecting", message: "\(peerID.displayName) is still connecting. Please wait.")
        case .discovered:
            showAlert("Waiting", message: "\(peerID.displayName) was found — invitation sent, waiting for response.")
        case .disconnected:
            showAlert("Disconnected", message: "\(peerID.displayName) lost connection. It will be removed shortly.")
        }
    }

    @objc private func sendTapped() {
        let connectedPeers = peers.filter { $0.isConnected }.map { $0.peerID }
        guard !connectedPeers.isEmpty else { return }

        if connectedPeers.count == 1 {
            selectedPeerID = connectedPeers[0]
            openPicker()
        } else if let sel = selectedPeerID, connectedPeers.contains(sel) {
            openPicker()
        } else {
            let sheet = UIAlertController(
                title: "Choose Device",
                message: "Select which device to send the file to",
                preferredStyle: .actionSheet
            )
            connectedPeers.forEach { peer in
                sheet.addAction(UIAlertAction(title: peer.displayName, style: .default) { [weak self] _ in
                    self?.selectedPeerID = peer
                    self?.openPicker()
                })
            }
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            if let pop = sheet.popoverPresentationController {
                pop.sourceView = sendButton
                pop.sourceRect = sendButton.bounds
            }
            present(sheet, animated: true)
        }
    }

    private func openPicker() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
        picker.delegate             = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    private func showTransferCard(fileName: String, progress: Float) {
        isSendingFile = progress < 1.0
        transferProgress.update(fileName: fileName, progress: progress, isSending: isSendingFile)
        if transferCard.isHidden {
            transferCard.isHidden = false
            transferCard.alpha    = 0
            UIView.animate(withDuration: 0.3) { self.transferCard.alpha = 1 }
        }
    }

    private func hideTransferCard() {
        UIView.animate(withDuration: 0.35) {
            self.transferCard.alpha = 0
        } completion: { _ in
            self.transferCard.isHidden = true
            self.transferCard.alpha    = 1
        }
    }

    private func log(_ message: String) {
        let ts = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logTextView.text.append("\n[\(ts)] \(message)")
        let end = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(end)
    }

    @objc private func clearLog() {
        logTextView.text = "── Log cleared ──"
    }

    private func showAlert(_ title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

extension ViewController: MultipeerManagerDelegate {

    func manager(_ manager: MultipeerManager, peersDidUpdate updatedPeers: [NearPeer]) {
        self.peers = updatedPeers
        if let sel = selectedPeerID,
           !updatedPeers.contains(where: { $0.peerID == sel && $0.isConnected }) {
            selectedPeerID = nil
        }
        rebuildPeerRows()
    }

    func manager(_ manager: MultipeerManager, didLog message: String) {
        log(message)
    }

    func manager(_ manager: MultipeerManager, transferProgress progress: Float, fileName: String, isVisible: Bool) {
        if isVisible {
            showTransferCard(fileName: fileName, progress: progress)
        } else {
            hideTransferCard()
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        guard let targetPeer = selectedPeerID ?? multipeer.connectedPeers.first?.peerID else {
            log("⚠️ No connected peer available")
            return
        }
        isSendingFile = true
        showTransferCard(fileName: fileURL.lastPathComponent, progress: 0)
        multipeer.sendFile(at: fileURL, to: targetPeer) { _ in }
    }
}

final class EmptyStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        let cfg  = UIImage.SymbolConfiguration(pointSize: 38, weight: .thin)
        let icon = UIImageView(image: UIImage(systemName: "antenna.radiowaves.left.and.right", withConfiguration: cfg))
        icon.tintColor   = .nsTextTer
        icon.contentMode = .scaleAspectFit

        let title      = UILabel()
        title.text      = "No devices found yet"
        title.font      = UIFont.systemFont(ofSize: 15, weight: .medium)
        title.textColor = .nsTextSec
        title.textAlignment = .center

        let sub         = UILabel()
        sub.text         = "Enable Bluetooth & Wi-Fi on\nnearby devices running NearShare"
        sub.font         = UIFont.systemFont(ofSize: 12, weight: .regular)
        sub.textColor    = .nsTextTer
        sub.textAlignment = .center
        sub.numberOfLines = 2

        let stack      = UIStackView(arrangedSubviews: [icon, title, sub])
        stack.axis     = .vertical
        stack.spacing  = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 46),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])

        UIView.animate(withDuration: 1.4, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            icon.alpha = 0.3
        }
    }
}

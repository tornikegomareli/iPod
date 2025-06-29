import UIKit

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    private init() {
        prepareGenerators()
    }
    
    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionFeedback.prepare()
    }
    
    func wheelClick() {
        selectionFeedback.selectionChanged()
    }
    
    func buttonPress() {
        lightImpact.impactOccurred()
    }
    
    func centerButtonPress() {
        mediumImpact.impactOccurred()
    }
    
    func endOfListBounce() {
        heavyImpact.impactOccurred()
    }
}
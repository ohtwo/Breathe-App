//
//  ContentView.swift
//  BreatheAppCards
//
//  Created by Arlind Aliu on 30.09.19.
//  Copyright © 2019 Arlind Aliu. All rights reserved.
//

import SwiftUI
import Combine

enum CardPosition {
    case top, bottomn
}

struct DraggableCardView: View {
    @State var offset: CGPoint = CGPoint(x: 0, y: UIScreen.main.bounds.height*0.6)
    
    var contentView: CardContentView
    var cardSize = CGSize(width: 320, height: 450)
    
    var dragChanged: ((CGFloat) -> Void)?
    var dragEnded: ((CardPosition) -> Void)?
    
    private let minimumY: CGFloat = 0
    private var maximumY: CGFloat {
        get {
            UIScreen.main.bounds.height*0.6
        }
    }

    var percentChanged:CGFloat {
        get {
            return self.offset.y/(maximumY - minimumY)
        }
    }

    var body: some View {
        let dragGesture = DragGesture().onChanged({ value in
            
            self.dragChanged?(self.percentChanged)
            
            var offsetY = value.location.y - value.startLocation.y
            
            if offsetY < 0 { //Draging from bottom to the top
                offsetY = value.location.y - abs(offsetY)
            }
            
            let y = min(self.maximumY, max(self.minimumY, offsetY))
            let changedPoints = CGPoint(x: 0, y: y)
            self.offset = changedPoints
        }).onEnded { _ in
            if self.percentChanged > 0.5 {
                //Push it to the bottomn
                withAnimation(.easeIn(duration: 0.2)) {
                    self.offset = CGPoint(x: 0, y: self.maximumY)
                }
                
                self.dragEnded?(.bottomn)
            } else {
                //Push it to the top again
                withAnimation(.easeIn(duration: 0.2)) {
                    self.offset = CGPoint.zero
                }
                
                self.dragEnded?(.top)
            }
        }
        
        return RoundedRectangle(cornerRadius: 8.0)
            .foregroundColor(Color.cardGray)
            .overlay(contentView)
            .overlay(RoundedRectangle(cornerRadius: 8.0)
            .strokeBorder(Color.textGray, style: StrokeStyle.init(lineWidth: 0.5)))
            .frame(width: cardSize.width, height: cardSize.height)
            .offset(x: 0, y: self.offset.y)
            .gesture(dragGesture)
    }
}

//Mark: Model
struct Card: Identifiable {
    var id: Int
    var isDragging: Bool = false
    var percentPresented: CGFloat = 0.0
    var position: CardPosition = .bottomn {
        didSet {
            self.percentPresented = (position == .top) ? 1.0 : 0.0
        }
    }
}

class CardStack: ObservableObject {
    @Published var allCards: [Card]

    var presentationPercentage: CGFloat {
        get {
            if topCards.isEmpty {
                return bottomnCards.last?.percentPresented ?? 0
            } else if topCards.count == 1 {
                return topCards.first?.percentPresented ?? 0
            } else {
                return 1.0
            }
        }
    }
    
    var bottomnCards: [Card] {
        return allCards.filter {
            $0.position == .bottomn
        }
    }
    
    var topCards: [Card] {
        return allCards.filter {
            $0.position == .top
        }
    }
    
    init(numberOfCards: Int) {
        self.allCards = (0..<numberOfCards).map {
            return Card(id: $0)
        }
    }
    
    func cardScale(_ card: Card) -> Double {
        let topIndex = self.topCards.firstIndex(where: {$0.id == card.id})
        let bottomIndex = self.bottomnCards.firstIndex(where: {$0.id == card.id})
        
        if let index = bottomIndex {
            return 1 - Double(bottomnCards.count - index)*0.03
        } else if let index = topIndex {
            return 1 - Double(index)*0.05
        }
        return 1
    }
    
    func cardOffset(_ card: Card) -> Double {
        let topIndex = self.topCards.firstIndex(where: {$0.id == card.id})
         let bottomIndex = self.bottomnCards.firstIndex(where: {$0.id == card.id})
         
         if let index = bottomIndex {
             return Double(index)
         } else if let index = topIndex {
             return 20*Double(index)
         }
         return 0
    }
}

struct CardStackView: View {
    @ObservedObject var cardStack: CardStack

    var body: some View {
        ZStack {
            ForEach(0..<self.cardStack.allCards.count) { i in
                self.cardAt(i)
            }
        }
    }
            
    func cardAt(_ i: Int) -> some View {
        let card = self.cardStack.allCards[i]
        let scale = CGFloat(self.cardStack.cardScale(card))
        let offset = CGFloat(self.cardStack.cardOffset(card))
        var zIndex = 0
        
        let cardView = DraggableCardView(contentView: CardContentView(exercise: Exercise.allExercises[i])
            , dragChanged: { percent in
            self.cardStack.allCards[i].percentPresented = 1 - percent
            self.cardStack.allCards[i].isDragging = true
        }, dragEnded: { position in
            self.cardStack.allCards[i].isDragging = false
            withAnimation{self.cardStack.allCards[i].position = position}
        })
        
        if card.isDragging {
            zIndex = self.cardStack.allCards.count
        } else {
            zIndex = (card.position == .top) ? (self.cardStack.allCards.count - i - 1) : 0
        }
        
        return cardView
        .offset(x: 0, y: offset)
        .scaleEffect(scale)
        .zIndex(Double(zIndex))
    }
    
}

struct ContentView : View {
    @ObservedObject var cardStack = CardStack(numberOfCards: Exercise.allExercises.count)
    
    var body: some View {
        ZStack {
            Rectangle().background(Color.black)
            .animation(.easeIn(duration: 0.4))
            .opacity(Double(cardStack.presentationPercentage))
            CardStackView(cardStack: cardStack)
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
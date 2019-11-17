//
//  CardStackView.swift
//  BreatheAppCards
//
//  Created by Arlind Aliu on 09.11.19.
//  Copyright © 2019 Arlind Aliu. All rights reserved.
//

import SwiftUI

enum CardPosition {
    case top, bottomn
}

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

struct DraggableCardView: View {
    @State var offset: CGPoint = CGPoint(x: 0, y: UIScreen.main.bounds.height*0.65)
    
    var contentView: CardContentView //TODO: Use View here || Or even better overlay it from outside
    @Binding var card: Card
    
    private let minimumY: CGFloat = 0
    private var maximumY: CGFloat {
        get {
            UIScreen.main.bounds.height*0.65
        }
    }

    var percentChanged:CGFloat {
        get {
            return self.offset.y/(maximumY - minimumY)
        }
    }

    var body: some View {
        let dragGesture = DragGesture().onChanged({ value in
            self.card.percentPresented = 1 - self.percentChanged
            
            var offsetY = value.location.y - value.startLocation.y
            
            if offsetY < 0 { //Draging from bottom to the top
                offsetY = value.location.y - abs(offsetY)
            }
            
            let y = min(self.maximumY, max(self.minimumY, offsetY))
            let changedPoints = CGPoint(x: 0, y: y)
            self.offset = changedPoints
            self.card.isDragging = true
            
        }).onEnded { _ in
            if self.percentChanged > 0.5 {
                //Push it to the bottomn
                withAnimation(.easeIn(duration: 0.2)) {
                    self.offset = CGPoint(x: 0, y: self.maximumY)
                    self.card.position = .bottomn
                    self.card.isDragging = false
                }
            } else {
                //Push it to the top again
                withAnimation(.easeIn(duration: 0.2)) {
                    self.offset = CGPoint.zero
                    self.card.position = .top
                    self.card.isDragging = false
                }
            }
        }
        
        return
             RoundedRectangle(cornerRadius: 8.0)
             .foregroundColor(Color.darkGrayColor)
             .overlay(self.contentView)
             .overlay(RoundedRectangle(cornerRadius: 8.0)
             .strokeBorder(Color.textGray, style: StrokeStyle.init(lineWidth: 0.5)))
             .offset(x: 0, y: self.offset.y)
             .gesture(dragGesture)
    }
}

struct CardStackView: View {
    @Binding var fullSizeCard: Bool
    @Binding var cards: [Card]
    
    private var bottomnCards: [Card] {
        return cards.filter {
            $0.position == .bottomn
        }
    }
    
    private var topCards: [Card] {
        return cards.filter {
            $0.position == .top
        }
    }

    var animationDuration: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<self.cards.count) { i in
                self.cardAt(i)
            }
        }
    }

    func cardAt(_ i: Int) -> some View {
        let card = cards[i]
        let scale = CGFloat(self.cardScale(card))
        let offset = CGFloat(self.cardOffset(card))
        var zIndex = 0
        

        let cardView = DraggableCardView(contentView: CardContentView(exercise: Exercise.allExercises[i]),
                                         card: self.$cards[i])
        .onTapGesture {
            withAnimation(Animation.easeIn(duration: self.animationDuration)) {self.fullSizeCard = true}
        }
        
        if card.isDragging {
            zIndex = self.cards.count
        } else {
            zIndex = (card.position == .top) ? (self.cards.count - i - 1) : 0
        }
           
        return cardView
            .padding(.horizontal, fullSizeCard ? 0 : 30)
            .padding(.vertical, fullSizeCard ? 0 : 160)
            .offset(y: offset)
            .scaleEffect(scale)
            .zIndex(Double(zIndex))
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
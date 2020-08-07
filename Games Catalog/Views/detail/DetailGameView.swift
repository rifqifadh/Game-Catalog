//
//  DetailView.swift
//  Games Catalog
//
//  Created by Rifqi Fadh on 03/07/20.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import AVKit

struct DetailGameView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject private var detailViewModel: DetailViewModel
    

    var fetchRequest: FetchRequest<Favorite>
    
    var games: FetchedResults<Favorite> { fetchRequest.wrappedValue }
    
    init(id: Int) {
        self._detailViewModel = ObservedObject(wrappedValue: DetailViewModel(id: id))
        self.fetchRequest = FetchRequest<Favorite>(entity: Favorite.entity(), sortDescriptors: [],
                                                   predicate: NSPredicate(format: "id == \(id)"))
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if detailViewModel.detailGames != nil {
                    VStack(alignment: .leading) {
                        if let url = URL(string: detailViewModel.detailGames?.clip?.clip ?? "") {
                            VideoPlayer(player: AVPlayer(url: url))
                                .frame(height: 280)
                        } else {
                            WebImage(url: URL(string: detailViewModel.detailGames?.backgroundImage ?? "")!)
                                .resizable()
                                .renderingMode(.original)
                                .placeholder {
                                    Rectangle().foregroundColor(.gray)}
                                .indicator(.activity)
                                .frame(height: 200)
                        }
                        DetailContentView(game: detailViewModel.detailGames!)
                            .padding([.top, .leading, .trailing])
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Screenshots")
                                .font(.headline)
                                .padding(.leading)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(detailViewModel.screenshots) { i in
                                        WebImage(url: URL(string: i.image))
                                            .resizable()
                                            .placeholder {
                                                Rectangle().foregroundColor(.gray)}
                                            .indicator(.activity)
                                            .cornerRadius(10)
                                            .scaledToFill()
                                            .frame(width: 240, height: 135)
                                            .padding(.horizontal, 5)
                                    }
                                    .edgesIgnoringSafeArea(.all)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        .frame(alignment: .center)
                        .background(Color("Background"))
                        .navigationBarItems(
                            trailing:
                                Button(action: {
                                    if detailViewModel.isFav {
                                        detailViewModel.deleteFav(from: games, moc)
                                    } else {
                                        detailViewModel.saveToFavorite(moc)
                                    }             
                                }) {
                                    Image(systemName: detailViewModel.isFav ? "star.fill" : "star")
                                }
                        )
                        .navigationBarTitle(Text("\(detailViewModel.detailGames!.name)"), displayMode: .inline)
                    }
                } else {
                    ProgressViewCustom()
                }
            }
            .onAppear {
                detailViewModel.getDetailMovie()
                detailViewModel.checkIsFav(games)
            }
        }
        .background(Color("Background"))
    }
}


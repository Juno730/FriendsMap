//
//  ImageDetailView.swift
//  FriendsMap
//
//  Created by Juno Lee on 10/21/24.
//

import SwiftUI
import CoreLocation

struct ContentDetailView: View {
    @EnvironmentObject var authStore: AuthenticationStore
    @Binding var annotations: [IdentifiableLocation]
    
    let identifiableLocation: IdentifiableLocation
    
    var body: some View {
        VStack {
            Spacer()

            PolaroidImageView(image: identifiableLocation.image, text: identifiableLocation.text, date: identifiableLocation.contentDate, nickname: identifiableLocation.nickname, profileImage: identifiableLocation.profileImage)
            
            Spacer()

        }
    }
}



struct PolaroidImageView: View {
    let image: Image
    let text: String
    let date: String
    let nickname: String
    let profileImage: UIImage
    
    @State private var isLiked: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Image(uiImage: profileImage)
                        .resizable()
                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Circle())
                    
                    Text(nickname)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(8)
                    
                    Spacer()
                    
                    Text("\(date)")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing], 12)
                    
                }.padding(.horizontal)
                
                VStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(geometry.size.width * 0.7, 380), height: 400)
                        .cornerRadius(5)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    HStack {
                            Text(text)
                                .font(.body)
                                .padding(.leading, 12)
                                .padding(.trailing, 12)
                                .padding(.top, 8)
                                .background(Color.white)
                                .cornerRadius(10)
                        
                        Spacer()
                        
                        Button(action: {
                            isLiked.toggle()
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .gray)
                                .font(.title)
                                .padding()
                        }
                    }.padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .frame(width: geometry.size.width, height: geometry.size.height) // GeometryReader의 크기를 맞춤
        }
        .padding(.horizontal) // 좌우 여백 추가
    }
}

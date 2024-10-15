//
//  SignInView.swift
//  FriendsMap
//
//  Created by 강승우 on 10/15/24.
//

import SwiftUI

struct SignInView: View {
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 20) {
                HStack { // 로고 크기 조절용
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: proxy.size.width * 0.5)
                .padding(.top, proxy.size.height * 0.1)
                
                Text("SIGN IN")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                
                createTextField(placeholder: "E-mail (xxx@.com 형식으로 입력해주세요)", varName: $email, isSecure: false)
                    .keyboardType(.emailAddress)
                    .frame(width: proxy.size.width * 0.85)
                    .padding(.top, proxy.size.height * 0.06)
              
                createTextField(placeholder: "Password", varName: $password, isSecure: true)
                    .frame(width: proxy.size.width * 0.85)
                            
                Button {
                    
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: proxy.size.width * 0.5, height: proxy.size.height * 0.05)
                            .foregroundStyle(Color(red: 147/255, green: 147/255, blue: 147/255))
                        Text("로그인")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, proxy.size.height * 0.04)
                    .padding(.bottom, proxy.size.height * 0.06)
                }
                
                Spacer()
                
                Text("소셜 계정으로 로그인하기")
                    .foregroundStyle(.white.opacity(0.7))
                
                HStack(spacing : proxy.size.width * 0.1) {
                    Button {
                        
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                            Image("googleLogo")
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                            Image("appleLogo")
                                .resizable()
                                .scaledToFit()
                                .padding()
                           
                        }
                    }
                }
                .frame(height: proxy.size.height * 0.1)
                .padding(.bottom, proxy.size.height * 0.1)
                
            }
            .frame(width:proxy.size.width, height: proxy.size.height)
            .background(.bgcolor)
        }
    }
}

#Preview {
    SignInView()
}

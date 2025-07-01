//
//  AddressDetailSetupView.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import SwiftUI

// MARK: - 주소 상세 설정 화면
struct AddressDetailSetupView: View {
    @State private var selectedType: LocationType = .custom
    @State private var addressName: String = ""
    @State private var detailAddress: String = ""
    @Environment(\.dismiss) private var dismiss

    let selectedLocation: Location
    let onSave: (String, LocationType, String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            headerSection

            // 메인 콘텐츠
            ScrollView {
                VStack(spacing: 24) {
                    selectedLocationInfo
                    addressTypeSelector
                    addressNameInput
                    detailAddressInput
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }

            // 하단 저장 버튼
            saveButton
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // 기본값 설정
            if let name = selectedLocation.name, !name.isEmpty {
                addressName = name
            }
        }
    }

    // MARK: - 헤더
    private var headerSection: some View {
        HStack {
            Button("뒤로가기") {
                dismiss()
            }
            .font(.system(size: 16))
            .foregroundColor(.deepSprout)

            Spacer()

            Text("주소 설정")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blackSprout)

            Spacer()

//            Button("완료") {
//                saveAddress()
//            }
//            .font(.system(size: 16, weight: .semibold))
//            .foregroundColor(canSave ? .deepSprout : .gray45)
//            .disabled(!canSave)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.brightSprout)
    }

    // MARK: - 선택된 주소 정보
    private var selectedLocationInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.deepSprout)

                Text("선택한 주소")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray60)
            }

            VStack(alignment: .leading, spacing: 6) {
                if let name = selectedLocation.name, !name.isEmpty {
                    Text(name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blackSprout)
                }

                Text(selectedLocation.address)
                    .font(.system(size: 14))
                    .foregroundColor(.gray60)
                    .lineLimit(nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray15)
        .cornerRadius(12)
    }

    // MARK: - 주소 타입 선택
    private var addressTypeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주소 타입")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blackSprout)

            HStack(spacing: 20) {
                ForEach(LocationType.allCases, id: \.self) { type in
                    TypeButton(
                        type: type,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                        updateDefaultName()
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - 주소 이름 입력
    private var addressNameInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주소 이름")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blackSprout)

            TextField("예: 우리집, 본사, 단골카페", text: $addressName)
                .font(.system(size: 16))
                .foregroundColor(.blackSprout)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.deepSprout.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - 상세 주소 입력
    private var detailAddressInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상세 주소 (선택사항)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blackSprout)

            TextField("예: 3층 301호, 후문 근처", text: $detailAddress)
                .font(.system(size: 16))
                .foregroundColor(.blackSprout)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.deepSprout.opacity(0.3), lineWidth: 1)
                )

            Text("건물 내 위치나 찾아가는 방법을 적어주세요")
                .font(.system(size: 12))
                .foregroundColor(.gray45)
        }
    }

    // MARK: - 저장 버튼
    private var saveButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray30)

            Button {
                saveAddress()
            } label: {
                Text("저장하기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canSave ? Color.deepSprout : Color.gray45)
                    .cornerRadius(12)
            }
            .disabled(!canSave)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }

    // MARK: - 저장 가능 여부
    private var canSave: Bool {
        !addressName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - 기본 이름 업데이트
    private func updateDefaultName() {
        if addressName.isEmpty || addressName == "집" || addressName == "회사" || addressName == selectedLocation.name {
            switch selectedType {
            case .home:
                addressName = "집"
            case .work:
                addressName = "회사"
            case .custom:
                addressName = selectedLocation.name ?? ""
            }
        }
    }

    // MARK: - 주소 저장
    private func saveAddress() {
        let name = addressName.trimmingCharacters(in: .whitespacesAndNewlines)
        let detail = detailAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        onSave(name, selectedType, detail)
        dismiss()
    }
}

// MARK: - 타입 선택 버튼
struct TypeButton: View {
    let type: LocationType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.deepSprout : Color.gray15)
                        .frame(width: 50, height: 50)

                    Image(systemName: type.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : .gray60)
                }

                Text(type.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Color.deepSprout : .gray60)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

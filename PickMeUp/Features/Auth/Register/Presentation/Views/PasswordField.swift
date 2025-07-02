import SwiftUI

struct PasswordField: View {
    let title: String
    let text: String
    let isPasswordVisible: Bool
    let validationMessage: String?
    let onChange: (String) -> Void
    let onToggleVisibility: () -> Void

    init(
        title: String,
        text: String,
        isPasswordVisible: Bool,
        validationMessage: String? = nil,
        onChange: @escaping (String) -> Void,
        onToggleVisibility: @escaping () -> Void
    ) {
        self.title = title
        self.text = text
        self.isPasswordVisible = isPasswordVisible
        self.validationMessage = validationMessage
        self.onChange = onChange
        self.onToggleVisibility = onToggleVisibility
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField(title, text: Binding(
                            get: { text },
                            set: { onChange($0) }
                        ))
                    } else {
                        SecureField(title, text: Binding(
                            get: { text },
                            set: { onChange($0) }
                        ))
                    }
                }
                .textInputAutocapitalization(.never)

                Button(action: onToggleVisibility) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .accessibilityLabel(Text(isPasswordVisible ? "비밀번호 숨기기" : "비밀번호 보기"))
                }
            }
            .textFieldStyle(.roundedBorder)

            Text(validationMessage ?? " ")
                .foregroundColor(.red)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
struct PasswordField_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var password = ""
        @State private var isVisible = false

        var body: some View {
            PasswordField(
                title: "Password",
                text: password,
                isPasswordVisible: isVisible,
                validationMessage: "비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다.",
                onChange: { password = $0 },
                onToggleVisibility: { isVisible.toggle() }
            )
            .padding()
        }
    }

    static var previews: some View {
        PreviewContainer()
            .previewLayout(.sizeThatFits)
    }
}
#endif

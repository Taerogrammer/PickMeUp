import SwiftUI

public struct PasswordField: View {
    public let title: String
    @Binding public var text: String
    @Binding public var isPasswordVisible: Bool
    public var validationMessage: String?
    public var onToggleVisibility: () -> Void

    public init(
        title: String,
        text: Binding<String>,
        isPasswordVisible: Binding<Bool>,
        validationMessage: String? = nil,
        onToggleVisibility: @escaping () -> Void
    ) {
        self.title = title
        self._text = text
        self._isPasswordVisible = isPasswordVisible
        self.validationMessage = validationMessage
        self.onToggleVisibility = onToggleVisibility
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isPasswordVisible {
                    TextField(title, text: $text)
                        .autocapitalization(.none)
                } else {
                    SecureField(title, text: $text)
                        .autocapitalization(.none)
                }
                Button(action: onToggleVisibility) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .textFieldStyle(.roundedBorder)

            Text(validationMessage ?? "")
                .foregroundColor(.red)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
struct PasswordField_Previews: PreviewProvider {
    @State static var password = ""
    @State static var isVisible = false
    static var previews: some View {
        PasswordField(
            title: "Password",
            text: $password,
            isPasswordVisible: $isVisible,
            validationMessage: "비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다.",
            onToggleVisibility: { isVisible.toggle() }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif 
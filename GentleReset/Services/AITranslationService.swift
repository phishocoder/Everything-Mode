import Foundation

struct AdminSnapshotPayload: Codable {
    let pressureSources: [String]
    let emotionalWeight: String
    let canWait: String
    let nextMove: String
}

enum AITranslationError: LocalizedError {
    case missingAPIKey
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your OpenAI API key to translate."
        case .invalidResponse:
            return "Could not parse a usable snapshot."
        }
    }
}

struct AITranslationService {
    private let session: URLSession
    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let model = "gpt-4.1-mini"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func buildSnapshot(from rawInput: String, apiKey: String) async throws -> AdminSnapshot {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AITranslationError.missingAPIKey
        }

        let body = ResponsesRequest(
            model: model,
            temperature: 0.2,
            input: [
                .init(
                    role: "system",
                    content: [
                        .init(
                            type: "input_text",
                            text: "You convert messy overwhelm notes into one concise admin snapshot. Be specific, concrete, and neutral. No encouragement or coaching. Return JSON only."
                        )
                    ]
                ),
                .init(
                    role: "user",
                    content: [
                        .init(
                            type: "input_text",
                            text: "Raw input:\n\(trimmed)\n\nReturn JSON with keys: pressureSources (array of 1-2 strings), emotionalWeight (string), canWait (string), nextMove (string). Keep each value under 16 words and concrete."
                        )
                    ]
                )
            ]
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AITranslationError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(ResponsesResult.self, from: data)
        guard
            let text = decoded.outputText,
            let payload = try parsePayload(from: text)
        else {
            throw AITranslationError.invalidResponse
        }

        return AdminSnapshot(
            createdAt: Date(),
            pressureItems: Array(payload.pressureSources.prefix(2)),
            emotionalWeight: payload.emotionalWeight,
            safeToIgnoreToday: payload.canWait,
            nextMove: payload.nextMove
        )
    }

    private func parsePayload(from text: String) throws -> AdminSnapshotPayload? {
        if let data = text.data(using: .utf8), let payload = try? JSONDecoder().decode(AdminSnapshotPayload.self, from: data) {
            return payload
        }

        guard
            let start = text.firstIndex(of: "{"),
            let end = text.lastIndex(of: "}")
        else {
            return nil
        }

        let jsonString = String(text[start...end])
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try JSONDecoder().decode(AdminSnapshotPayload.self, from: data)
    }
}

private struct ResponsesRequest: Codable {
    let model: String
    let temperature: Double
    let input: [ResponsesInputItem]
}

private struct ResponsesInputItem: Codable {
    let role: String
    let content: [ResponsesInputContent]
}

private struct ResponsesInputContent: Codable {
    let type: String
    let text: String
}

private struct ResponsesResult: Codable {
    let output: [ResponsesOutputItem]?

    var outputText: String? {
        output?
            .flatMap(\ .content)
            .first(where: { $0.type == "output_text" })?
            .text
    }
}

private struct ResponsesOutputItem: Codable {
    let content: [ResponsesOutputContent]
}

private struct ResponsesOutputContent: Codable {
    let type: String
    let text: String?
}

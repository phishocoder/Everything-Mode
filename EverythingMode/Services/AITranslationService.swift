import Foundation

struct AdminSnapshotPayload: Codable {
    let pressureSources: [String]
    let emotionalWeight: String
    let canWait: String
    let nextMove: String
}

enum AITranslationError: LocalizedError {
    case backendNotConfigured
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .backendNotConfigured:
            return "Translation backend key is not configured yet."
        case .invalidResponse:
            return "Could not parse a usable snapshot."
        }
    }
}

struct AITranslationService {
    private let session: URLSession
    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let model = "gpt-4.1-mini"
    private let apiKey: String?

    init(session: URLSession = .shared, apiKey: String? = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]) {
        self.session = session
        self.apiKey = apiKey
    }

    func buildSnapshot(from rawInput: String) async throws -> AdminSnapshot {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let apiKey, !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AITranslationError.backendNotConfigured
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
                            text: systemPrompt
                        )
                    ]
                ),
                .init(
                    role: "user",
                    content: [
                        .init(
                            type: "input_text",
                            text: userPrompt(for: trimmed)
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

    private var systemPrompt: String {
        """
        You are an AI translator for an app called Everything Mode.

        Your job is NOT to coach, motivate, therapize, or expand ideas.
        Your job is to translate raw human overwhelm into a clear, accurate admin snapshot.

        The user has just completed a brief regulation step.
        They may still feel fragile, distracted, or mentally tired.

        Your output must feel:
        - precise
        - relieving
        - grounded
        - trustworthy

        If the output feels generic, inspirational, or verbose, you have failed.

        --------------------------------
        INPUT CONTEXT
        --------------------------------

        You will receive unstructured input that may be:
        - emotional
        - messy
        - incomplete
        - stream-of-consciousness
        - voice-transcribed
        - partially contradictory

        Do NOT correct tone.
        Do NOT add moral framing.
        Do NOT assume ambition.

        Treat the input as a signal, not a story.

        --------------------------------
        CORE TASK
        --------------------------------

        Translate the input into ONE “Admin Snapshot.”

        This snapshot should help the user understand:
        - what is actually creating pressure
        - what can safely wait
        - what one small next move would reduce load

        You are finishing the thought the user cannot finish themselves.

        --------------------------------
        OUTPUT RULES (STRICT)
        --------------------------------

        1. Use plain, adult language.
        2. No emojis.
        3. No motivational phrases.
        4. No questions.
        5. No more than 6 total bullets across all sections.
        6. If something is ambiguous, choose the most likely interpretation and state it plainly.
        7. Accuracy > completeness.
        8. If the input contains multiple themes, prioritize the ones with admin or life-friction impact.

        --------------------------------
        OUTPUT FORMAT (EXACT)
        --------------------------------

        Title:
        What’s actually here

        Section 1: Pressure sources
        - 1–2 concrete admin items (specific, named plainly)
        - 1 emotional weight (named, not explained or solved)

        Section 2: What can wait
        - 1 item that is explicitly safe to ignore today

        Section 3: Next move
        - 1 small, concrete action that reduces pressure
        - Must be doable in under 10 minutes
        - Must not require motivation, planning, or willpower

        --------------------------------
        QUALITY BAR
        --------------------------------

        The user should read this and think:
        “Yes. That’s what I meant.”
        Not:
        “This sounds nice.”
        Not:
        “I could’ve done this myself.”

        Do not add anything extra.
        End cleanly.
        """
    }

    private func userPrompt(for rawInput: String) -> String {
        """
        Raw input:
        \(rawInput)

        Return JSON only with keys:
        - pressureSources: array with 1-2 strings
        - emotionalWeight: string
        - canWait: string
        - nextMove: string

        Keep each value concrete and concise.
        """
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

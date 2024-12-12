import AppMetricaCore

final class MetricaService {
    static let shared = MetricaService()

    private init() {}

    func reportEvent(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen,
        ]

        if let item = item {
            params["item"] = item
        }

        AppMetrica.reportEvent(
            name: "EVENT", parameters: params,
            onFailure: { error in
                print("REPORT ERROR: \(error.localizedDescription)")
            })

        if event != "open", event != "close" {
            print("Reported Event - Event: \(event), Screen: \(screen), Item: \(item ?? "N/A")")
        } else {
            print("Reported Event - Event: \(event), Screen: \(screen)")
        }
    }
}

/// A source-stable duration value for `Task.sleep(for:)`.
///
/// Swift's native `Duration` type is not available on SwiftUIKit's oldest
/// deployment targets. This type keeps the modern call-site shape available
/// while still using `Task.sleep(nanoseconds:)` under the hood.
public struct TaskSleepDuration: Equatable, Sendable {
    let nanoseconds: UInt64

    private init(nanoseconds: UInt64) {
        self.nanoseconds = nanoseconds
    }

    /// Creates a duration from nanoseconds.
    public static func nanoseconds<Value: BinaryInteger>(
        _ value: Value
    ) -> TaskSleepDuration {
        scaled(
            value,
            by: 1
        )
    }

    /// Creates a duration from microseconds.
    public static func microseconds<Value: BinaryInteger>(
        _ value: Value
    ) -> TaskSleepDuration {
        scaled(
            value,
            by: 1_000
        )
    }

    /// Creates a duration from milliseconds.
    public static func milliseconds<Value: BinaryInteger>(
        _ value: Value
    ) -> TaskSleepDuration {
        scaled(
            value,
            by: 1_000_000
        )
    }

    /// Creates a duration from seconds.
    public static func seconds<Value: BinaryInteger>(
        _ value: Value
    ) -> TaskSleepDuration {
        scaled(
            value,
            by: 1_000_000_000
        )
    }

    /// Creates a duration from fractional seconds.
    public static func seconds(
        _ value: Double
    ) -> TaskSleepDuration {
        scaled(
            value,
            by: 1_000_000_000
        )
    }

    private static func scaled<Value: BinaryInteger>(
        _ value: Value,
        by multiplier: UInt64
    ) -> TaskSleepDuration {
        guard value > 0 else {
            return TaskSleepDuration(nanoseconds: 0)
        }

        let clampedValue = UInt64(clamping: value)
        let (nanoseconds, didOverflow) = clampedValue.multipliedReportingOverflow(by: multiplier)

        return TaskSleepDuration(
            nanoseconds: didOverflow ? UInt64.max : nanoseconds
        )
    }

    private static func scaled(
        _ value: Double,
        by multiplier: Double
    ) -> TaskSleepDuration {
        guard value.isFinite, value > 0 else {
            return TaskSleepDuration(nanoseconds: 0)
        }

        let nanoseconds = value * multiplier

        guard nanoseconds < Double(UInt64.max) else {
            return TaskSleepDuration(nanoseconds: UInt64.max)
        }

        return TaskSleepDuration(nanoseconds: UInt64(nanoseconds))
    }
}

public extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for a duration.
    ///
    /// This mirrors the modern `Task.sleep(for:tolerance:)` call site while
    /// keeping projects that support older OS versions on the older
    /// nanosecond-based sleep primitive. The fallback preserves cancellation
    /// behavior through `Task.sleep(nanoseconds:)`. The `tolerance` value is
    /// accepted for source compatibility and ignored by the fallback.
    ///
    /// ```swift
    /// try await Task.sleep(for: .milliseconds(300))
    /// try await Task.sleep(
    ///     for: .seconds(1),
    ///     tolerance: .milliseconds(100)
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - duration: The amount of time to sleep.
    ///   - tolerance: An optional tolerance. The fallback ignores this value.
    static func sleep(
        for duration: TaskSleepDuration,
        tolerance: TaskSleepDuration? = nil
    ) async throws {
        _ = tolerance

        try await sleep(nanoseconds: duration.nanoseconds)
    }
}

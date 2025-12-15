import Foundation

extension Date {
    /// Get the start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Get the end of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Get the start of month
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Get the end of month
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }

    /// Get the start of year
    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Get the end of year
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfYear) ?? self
    }

    /// Check if date is in current fiscal year
    func isInCurrentFiscalYear(startMonth: Int = 1) -> Bool {
        let fiscalYearStart = getFiscalYearStart(for: self, startMonth: startMonth)
        let fiscalYearEnd = Calendar.current.date(byAdding: .year, value: 1, to: fiscalYearStart) ?? fiscalYearStart
        return self >= fiscalYearStart && self < fiscalYearEnd
    }

    /// Get fiscal year start date
    func getFiscalYearStart(for date: Date, startMonth: Int = 1) -> Date {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)

        var fiscalYear = year
        if month < startMonth {
            fiscalYear -= 1
        }

        var components = DateComponents()
        components.year = fiscalYear
        components.month = startMonth
        components.day = 1

        return Calendar.current.date(from: components) ?? date
    }

    /// Format date as accounting period (e.g., "Q1 2024" or "Jan 2024")
    func accountingPeriod(quarterly: Bool = false) -> String {
        if quarterly {
            let quarter = (Calendar.current.component(.month, from: self) - 1) / 3 + 1
            let year = Calendar.current.component(.year, from: self)
            return "Q\(quarter) \(year)"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: self)
        }
    }
}

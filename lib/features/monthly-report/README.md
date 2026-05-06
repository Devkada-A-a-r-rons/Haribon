# Monthly Report Feature

A comprehensive monthly trip analytics and reporting module for the Haribon application.

## Overview

The Monthly Report feature provides users with detailed analytics about their vehicle usage, fuel efficiency, and trip patterns across a calendar month. It includes performance insights, trend visualization, and actionable recommendations.

## Architecture

### Directory Structure

```
monthly-report/
├── models/
│   ├── monthly_report_model.dart    # Core data models
│   └── index.dart                   # Barrel export
├── screens/
│   ├── monthly_report_screen.dart   # Main screen component
│   └── index.dart                   # Barrel export
├── widgets/
│   ├── monthly_report_header.dart      # Header with overview metrics
│   ├── monthly_stats_card.dart         # Performance statistics card
│   ├── efficiency_trend_chart.dart     # Efficiency trend visualization
│   ├── vehicle_usage_calendar.dart     # Vehicle usage heatmap
│   ├── top_insight_card.dart           # Monthly insight recommendation
│   ├── daily_trips_list.dart           # Expandable daily trips list
│   └── index.dart                      # Barrel export
└── README.md                        # This file
```

## Models

### MonthlyReport
The main data model containing:
- Period information (month, year)
- Aggregated statistics (total trips, distance, fuel cost, emissions)
- Average efficiency score
- Daily trip breakdowns
- Performance metrics and trends
- Vehicle usage patterns
- Top insights and recommendations

### MonthlyStats
Contains aggregated performance metrics:
- Average fuel cost per trip
- Average distance per trip
- Average emissions per trip
- Best and worst efficiency scores
- Average speed
- Active days count

### Supporting Models
- `DailyTripSummary`: Daily aggregation of trips
- `TripEntry`: Individual trip details
- `TrendData`: Efficiency trend data point
- `VehicleUsageDay`: Daily vehicle usage tracking

## Screens

### MonthlyReportScreen
Main stateful widget that:
- Manages report data fetching and state
- Integrates with CommonAppBar for consistent styling
- Integrates with CommonNavBar for navigation
- Renders all report widgets in a scrollable list
- Supports month/year filtering
- Provides error handling and loading states

**Usage:**
```dart
MonthlyReportScreen(
  month: 'May',
  year: '2026',
  selectedNavIndex: 5,
  onNavIndexChanged: (index) {
    // Handle navigation
  },
)
```

## Widgets

### 1. MonthlyReportHeader
Displays the report period and key overview metrics in a 2x2 grid:
- Total Fuel Cost
- Total Distance
- CO2 Emissions
- Average Efficiency

### 2. MonthlyStatsCard
Shows performance insights including:
- Average cost per trip
- Average distance per trip
- Average speed
- Active days
- Best efficiency score
- Lowest efficiency score

### 3. EfficiencyTrendChart
Visual representation of efficiency scores throughout the month:
- Normalized bar chart
- Color-coded by performance level
- Shows score and day labels

### 4. VehicleUsageCalendar
Calendar-style grid showing vehicle usage:
- Color-coded by usage intensity
- Trip count indicator
- Legend for interpretation
- 7-column calendar layout

### 5. TopInsightCard
Displays the monthly insight/recommendation:
- AI-generated or manually curated
- Premium design with gradient background
- Easy to understand actionable advice

### 6. DailyTripsList
Expandable list of daily trips:
- Day summary with total distance and cost
- Efficiency badge for each day
- Click to expand individual trip details
- Shows origin, destination, time, distance, and cost for each trip

## Styling

All widgets use:
- **Colors**: AppColors theme from `theme/app_colors.dart`
- **Typography**: Google Fonts (Inter, Poppins) from `theme/app_text_styles.dart`
- **Layout**: Consistent spacing and padding following Material Design 3
- **Components**: Common AppBar and NavBar from `features/common/`

## Data Flow

1. **MonthlyReportScreen** initializes and fetches report data
2. Data is processed into **MonthlyReport** object
3. Individual widgets consume relevant data:
   - Header → overview metrics
   - Stats → performance insights
   - Trends → efficiency visualization
   - Calendar → usage patterns
   - Insight → recommendations
   - Trips → detailed breakdown

## Integration Points

### In Summary Screen
Add navigation to monthly report from the summary page:
```dart
OutlinedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MonthlyReportScreen(),
      ),
    );
  },
  icon: const Icon(Icons.bar_chart_rounded),
  label: const Text('View Monthly Report'),
)
```

### In Main App Navigation
Add to CommonNavBar tabs if needed, or trigger from summary screen.

## Features

- ✅ Responsive design for multiple screen sizes
- ✅ Modular widget architecture
- ✅ Consistent theming with app design system
- ✅ Error handling and loading states
- ✅ Expandable trip details
- ✅ Visual trend analysis
- ✅ Calendar-style usage tracking
- ✅ AI-powered insights (integration ready)
- ✅ Production-ready code structure

## Future Enhancements

- [ ] Real data integration with Supabase
- [ ] Export reports as PDF
- [ ] Comparison with previous months
- [ ] Custom date range selection
- [ ] Share insights functionality
- [ ] Real-time data updates
- [ ] Advanced filtering options
- [ ] Performance predictions

## Best Practices

1. **Data Fetching**: Implement Supabase integration in `_fetchMonthlyReport()`
2. **Error Handling**: All network calls should be wrapped in try-catch
3. **State Management**: Keep report data in `_report` variable
4. **Performance**: Use `const` constructors where applicable
5. **Accessibility**: All interactive elements have proper labels
6. **Localization**: Use format methods for currency and dates

## Testing

Consider testing:
- Different month lengths (28-31 days)
- Edge cases (no trips, single trip)
- Empty states
- Data generation consistency
- Navigation integration
- Responsive layout on various screen sizes

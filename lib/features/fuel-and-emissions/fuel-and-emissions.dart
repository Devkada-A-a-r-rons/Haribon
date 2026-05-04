import 'package:flutter/material.dart';

import '../common/widgets/app_bar.dart';
import 'widgets/total_fuel_card.dart';
import 'widgets/fuel_consumption_breakdown_card.dart';
import 'widgets/total_fuel_cost_card.dart';
import 'widgets/total_co2_card.dart';
import 'widgets/efficiency_loss_insights_card.dart';
import 'widgets/optimization_tips_card.dart';

class FuelAndEmissionsScreen extends StatelessWidget {
  const FuelAndEmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: 'Fuel & Emissions',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF1B2430)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: const [
              TotalFuelCard(),
              SizedBox(height: 16),
              FuelConsumptionBreakdownCard(),
              SizedBox(height: 16),
              TotalFuelCostCard(),
              SizedBox(height: 16),
              TotalCo2Card(),
              SizedBox(height: 16),
              EfficiencyLossInsightsCard(),
              SizedBox(height: 16),
              OptimizationTipsCard(),
              SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }
}

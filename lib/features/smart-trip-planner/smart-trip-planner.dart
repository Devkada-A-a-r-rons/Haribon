import 'package:flutter/material.dart';
import 'widgets/insight_card.dart';
import 'widgets/expandable_card.dart';
import 'widgets/refueling_planner_content.dart';
import 'widgets/expense_planner_content.dart';
import 'widgets/visual_breakdown_card.dart';
import 'widgets/bottom_action_card.dart';
import 'widgets/fuel_readiness_card.dart';

class SmartTripPlanner extends StatefulWidget {
  const SmartTripPlanner({super.key});

  @override
  State<SmartTripPlanner> createState() => _SmartTripPlannerState();
}

class _SmartTripPlannerState extends State<SmartTripPlanner> {
  int _selectedIndex = 1; // PLANNER

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2430)),
          onPressed: () {},
        ),
        title: Center(
          child: Text(
            'Smart Trip\nBudget\nPlanner',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFF1B2430),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              height: 1.1,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF1B2430)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // BUDGET STATUS SECTION
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CURRENT BUDGET STATUS',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF3B5B78),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₱2,500',
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1B2430),
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Budget',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7B8A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Gradient progress bar
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9CBEE1), Color(0xFFC8E6C9)],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Est. Cost: ₱2,680',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFC62828),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Balance: -₱180',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8F9FAA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // AI BUDGET INSIGHTS
              const InsightCard(),
              const SizedBox(height: 16),

              // FUEL READINESS
              const FuelReadinessCard(),
              const SizedBox(height: 16),

              // REFUELING PLANNER
              const ExpandableCard(
                icon: Icons.map_outlined,
                title: 'Smart Refueling\nPlanner',
                subtitle: '',
                subtitleColor: Colors.transparent,
                content: RefuelingPlannerContent(),
                initiallyExpanded: true,
              ),
              const SizedBox(height: 16),

              // EXPENSE PLANNER
              const ExpandableCard(
                icon: Icons.payments_outlined,
                title: 'Expense\nPlanner',
                subtitle: '₱2,680\nEstimated',
                subtitleColor: Color(0xFF3B5B78),
                content: ExpensePlannerContent(),
                initiallyExpanded: true,
              ),
              const SizedBox(height: 16),

              // VISUAL BREAKDOWN
              const VisualBreakdownCard(),
              const SizedBox(height: 16),

              // BOTTOM IMAGE CARD
              const BottomActionCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2962FF),
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 8, letterSpacing: 0.5),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4.0, top: 4.0), child: Icon(Icons.explore_outlined, size: 20)),
            label: 'EXPLORE',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4.0, top: 4.0), 
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_outlined, size: 20, color: Color(0xFF2962FF)),
              )
            ),
            label: 'PLANNER',
          ),
          const BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4.0, top: 4.0), child: Icon(Icons.bar_chart_outlined, size: 20)),
            label: 'INSIGHTS',
          ),
          const BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4.0, top: 4.0), child: Icon(Icons.person_outline, size: 20)),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}
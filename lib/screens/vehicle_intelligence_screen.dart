import 'package:flutter/material.dart';

import '../widgets/vehicle_intelligence/compact_dropdown.dart';
import '../widgets/vehicle_intelligence/compact_text_field.dart';
import '../widgets/vehicle_intelligence/info_card.dart';
import '../widgets/vehicle_intelligence/efficiency_card.dart';

class VehicleIntelligenceScreen extends StatefulWidget {
  const VehicleIntelligenceScreen({super.key});

  @override
  State<VehicleIntelligenceScreen> createState() => _VehicleIntelligenceScreenState();
}

class _VehicleIntelligenceScreenState extends State<VehicleIntelligenceScreen> {
  int _selectedIndex = 3; // Setting profile as selected based on image
  double _fuelLevel = 0.35; // 35% based on the image

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Center(
          child: Text(
            'Haribon',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              letterSpacing: 4.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: Colors.blue.shade300),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Vehicle Intelligence Setup',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure your vehicle\'s specifications to enable precision range estimation and efficiency tracking.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),

                // Route Setup
                const CompactTextField(
                  label: 'Starting Point',
                  hintText: 'Enter starting city or address',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                const CompactTextField(
                  label: 'Destination',
                  hintText: 'Enter destination city or address',
                  prefixIcon: Icons.change_history_outlined,
                ),
                const SizedBox(height: 12),

                // Dropdowns (Vertical list)
                const CompactDropdown(label: 'Vehicle Type', value: 'SUV'),
                const SizedBox(height: 12),
                const CompactDropdown(label: 'Fuel Type', value: 'Gasoline'),
                const SizedBox(height: 12),
                const CompactDropdown(label: 'Brand', value: 'Toyota'),
                const SizedBox(height: 12),
                const CompactDropdown(label: 'Model', value: 'Vios'),
                const SizedBox(height: 20),

                // Current Fuel Level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Fuel Level',
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                        Text(
                          '${(_fuelLevel * 100).toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF3B5B78),
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '14.7L / 42L',
                        style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Gradient Slider
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) {
                        setState(() {
                          double left = (details.localPosition.dx - 8).clamp(0.0, constraints.maxWidth - 16.0);
                          _fuelLevel = left / (constraints.maxWidth - 16.0);
                        });
                      },
                      onTapDown: (details) {
                        setState(() {
                          double left = (details.localPosition.dx - 8).clamp(0.0, constraints.maxWidth - 16.0);
                          _fuelLevel = left / (constraints.maxWidth - 16.0);
                        });
                      },
                      child: Container(
                        height: 24, // Compact hit area
                        alignment: Alignment.centerLeft,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              width: constraints.maxWidth,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFC62828), Color(0xFFF0E5D8), Color(0xFF4A6B5D)],
                                ),
                              ),
                            ),
                            Positioned(
                              left: _fuelLevel * (constraints.maxWidth - 16.0),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF3B5B78), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('E', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                    Text('F', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF567261), // Dark green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Text('Save Configuration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    label: const Icon(Icons.auto_awesome, size: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Cards Area
                InfoCard(
                  icon: Icons.local_gas_station_outlined,
                  title: 'Current Fuel Estimate',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${(_fuelLevel * 100).toInt()}%',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '(14.7 Liters)',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Based on a 42L tank capacity\nfor standard SUV profiles.',
                        style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'Estimated Range',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '450 km',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('City Range', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text('380 km', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Highway Range', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text('520 km', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const EfficiencyCard(),
                const SizedBox(height: 12),
                InfoCard(
                  icon: Icons.route_outlined,
                  title: 'Trip Readiness Preview',
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      '"Enter a route to check if your current fuel can complete the trip."',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5B87FB),
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
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0, top: 4.0),
                child: Icon(Icons.calendar_today_outlined, size: 20),
              ),
              label: 'PLANNER',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0, top: 4.0),
                child: Icon(Icons.receipt_long_outlined, size: 20),
              ),
              label: 'EXPENSES',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0, top: 4.0),
                child: Icon(Icons.map_outlined, size: 20),
              ),
              label: 'ROUTES',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0, top: 4.0),
                child: Icon(Icons.person_outline, size: 20),
              ),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }


}



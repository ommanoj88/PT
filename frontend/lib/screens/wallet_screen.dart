import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Screen to view wallet balance and buy credits.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _credits = 0;
  bool _isLoading = true;
  bool _isPurchasing = false;

  // Available packages
  static const List<Map<String, dynamic>> _packages = [
    {'amount': 50, 'price': '₹500', 'label': 'Starter'},
    {'amount': 100, 'price': '₹1,000', 'label': 'Popular'},
    {'amount': 250, 'price': '₹2,000', 'label': 'Value'},
    {'amount': 500, 'price': '₹3,500', 'label': 'Premium'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credits = await WalletService.getBalance();
      setState(() {
        _credits = credits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _purchasePackage(Map<String, dynamic> package) async {
    if (_isPurchasing) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isPurchasing = true;
    });

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Processing...',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    try {
      final newBalance = await WalletService.addCredits(package['amount'] as int);

      if (mounted) {
        Navigator.pop(context); // Close processing dialog

        setState(() {
          _credits = newBalance;
          _isPurchasing = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.success, AppTheme.success.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  'Success!',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  '${package['amount']} Sparks added to your wallet',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close processing dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Balance Card
                  _buildBalanceCard(colorScheme, textTheme),
                  const SizedBox(height: AppTheme.spacing32),
                  // Packages
                  Text(
                    'Buy Sparks',
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  ...List.generate(
                    _packages.length,
                    (index) => AnimatedListItem(
                      index: index,
                      child: _buildPackageCard(_packages[index], colorScheme, textTheme),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Balance',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.yellow, size: 40),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                '$_credits',
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            'Sparks',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    Map<String, dynamic> package,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isPopular = package['label'] == 'Popular';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: 0,
                right: AppTheme.spacing16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppTheme.radiusSmall),
                      bottomRight: Radius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  child: Text(
                    'Popular',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.yellow,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${package['amount']} Sparks',
                          style: textTheme.titleLarge,
                        ),
                        Text(
                          package['label'],
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassButton(
                    onTap: _isPurchasing ? null : () => _purchasePackage(package),
                    isLoading: _isPurchasing,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing20,
                      vertical: AppTheme.spacing12,
                    ),
                    child: Text(
                      package['price'],
                      style: textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

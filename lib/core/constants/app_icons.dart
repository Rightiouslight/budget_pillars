import 'package:flutter/material.dart';

/// Icon data with metadata for selection UI
class IconOption {
  final IconData iconData;
  final String name;
  final int codePoint;

  const IconOption({
    required this.iconData,
    required this.name,
    required this.codePoint,
  });
}

/// Valid icons for different card types
class AppIcons {
  // Account icons - Banking & Finance
  static final List<IconOption> accountIcons = [
    IconOption(
      iconData: Icons.account_balance,
      name: 'Bank',
      codePoint: Icons.account_balance.codePoint,
    ),
    IconOption(
      iconData: Icons.account_balance_wallet,
      name: 'Wallet',
      codePoint: Icons.account_balance_wallet.codePoint,
    ),
    IconOption(
      iconData: Icons.credit_card,
      name: 'Credit Card',
      codePoint: Icons.credit_card.codePoint,
    ),
    IconOption(
      iconData: Icons.savings,
      name: 'Savings',
      codePoint: Icons.savings.codePoint,
    ),
    IconOption(
      iconData: Icons.attach_money,
      name: 'Money',
      codePoint: Icons.attach_money.codePoint,
    ),
    IconOption(
      iconData: Icons.paid,
      name: 'Paid',
      codePoint: Icons.paid.codePoint,
    ),
    IconOption(
      iconData: Icons.business,
      name: 'Business',
      codePoint: Icons.business.codePoint,
    ),
    IconOption(
      iconData: Icons.store,
      name: 'Store',
      codePoint: Icons.store.codePoint,
    ),
    IconOption(
      iconData: Icons.work,
      name: 'Work',
      codePoint: Icons.work.codePoint,
    ),
    IconOption(
      iconData: Icons.home,
      name: 'Home',
      codePoint: Icons.home.codePoint,
    ),
    IconOption(
      iconData: Icons.apartment,
      name: 'Apartment',
      codePoint: Icons.apartment.codePoint,
    ),
    IconOption(
      iconData: Icons.school,
      name: 'School',
      codePoint: Icons.school.codePoint,
    ),
    IconOption(
      iconData: Icons.local_hospital,
      name: 'Hospital',
      codePoint: Icons.local_hospital.codePoint,
    ),
    IconOption(
      iconData: Icons.directions_car,
      name: 'Car',
      codePoint: Icons.directions_car.codePoint,
    ),
    IconOption(
      iconData: Icons.flight,
      name: 'Flight',
      codePoint: Icons.flight.codePoint,
    ),
    IconOption(
      iconData: Icons.shopping_bag,
      name: 'Shopping',
      codePoint: Icons.shopping_bag.codePoint,
    ),
    IconOption(
      iconData: Icons.star,
      name: 'Star',
      codePoint: Icons.star.codePoint,
    ),
    IconOption(
      iconData: Icons.bookmark,
      name: 'Bookmark',
      codePoint: Icons.bookmark.codePoint,
    ),
    IconOption(
      iconData: Icons.favorite,
      name: 'Favorite',
      codePoint: Icons.favorite.codePoint,
    ),
    IconOption(
      iconData: Icons.business_center,
      name: 'Portfolio',
      codePoint: Icons.business_center.codePoint,
    ),
  ];

  // Pocket icons - Money containers & goals
  static final List<IconOption> pocketIcons = [
    IconOption(
      iconData: Icons.folder,
      name: 'Folder',
      codePoint: Icons.folder.codePoint,
    ),
    IconOption(
      iconData: Icons.folder_special,
      name: 'Special Folder',
      codePoint: Icons.folder_special.codePoint,
    ),
    IconOption(
      iconData: Icons.inbox,
      name: 'Inbox',
      codePoint: Icons.inbox.codePoint,
    ),
    IconOption(
      iconData: Icons.inventory_2,
      name: 'Box',
      codePoint: Icons.inventory_2.codePoint,
    ),
    IconOption(
      iconData: Icons.wallet,
      name: 'Wallet',
      codePoint: Icons.wallet.codePoint,
    ),
    IconOption(
      iconData: Icons.savings,
      name: 'Piggy Bank',
      codePoint: Icons.savings.codePoint,
    ),
    IconOption(
      iconData: Icons.money,
      name: 'Cash',
      codePoint: Icons.money.codePoint,
    ),
    IconOption(
      iconData: Icons.paid,
      name: 'Payment',
      codePoint: Icons.paid.codePoint,
    ),
    IconOption(
      iconData: Icons.diamond,
      name: 'Diamond',
      codePoint: Icons.diamond.codePoint,
    ),
    IconOption(
      iconData: Icons.star,
      name: 'Star',
      codePoint: Icons.star.codePoint,
    ),
    IconOption(
      iconData: Icons.grade,
      name: 'Grade',
      codePoint: Icons.grade.codePoint,
    ),
    IconOption(
      iconData: Icons.emoji_events,
      name: 'Trophy',
      codePoint: Icons.emoji_events.codePoint,
    ),
    IconOption(
      iconData: Icons.card_giftcard,
      name: 'Gift',
      codePoint: Icons.card_giftcard.codePoint,
    ),
    IconOption(
      iconData: Icons.redeem,
      name: 'Redeem',
      codePoint: Icons.redeem.codePoint,
    ),
    IconOption(
      iconData: Icons.label,
      name: 'Label',
      codePoint: Icons.label.codePoint,
    ),
    IconOption(
      iconData: Icons.bookmark,
      name: 'Bookmark',
      codePoint: Icons.bookmark.codePoint,
    ),
    IconOption(
      iconData: Icons.stars,
      name: 'Stars',
      codePoint: Icons.stars.codePoint,
    ),
    IconOption(
      iconData: Icons.workspace_premium,
      name: 'Premium',
      codePoint: Icons.workspace_premium.codePoint,
    ),
  ];

  // Category icons - Spending categories with comprehensive coverage
  static final List<IconOption> categoryIcons = [
    // Food & Dining
    IconOption(
      iconData: Icons.restaurant,
      name: 'Restaurant',
      codePoint: Icons.restaurant.codePoint,
    ),
    IconOption(
      iconData: Icons.fastfood,
      name: 'Fast Food',
      codePoint: Icons.fastfood.codePoint,
    ),
    IconOption(
      iconData: Icons.local_cafe,
      name: 'Cafe',
      codePoint: Icons.local_cafe.codePoint,
    ),
    IconOption(
      iconData: Icons.local_pizza,
      name: 'Pizza',
      codePoint: Icons.local_pizza.codePoint,
    ),
    IconOption(
      iconData: Icons.local_bar,
      name: 'Bar',
      codePoint: Icons.local_bar.codePoint,
    ),
    IconOption(
      iconData: Icons.lunch_dining,
      name: 'Lunch',
      codePoint: Icons.lunch_dining.codePoint,
    ),
    IconOption(
      iconData: Icons.dinner_dining,
      name: 'Dinner',
      codePoint: Icons.dinner_dining.codePoint,
    ),
    IconOption(
      iconData: Icons.breakfast_dining,
      name: 'Breakfast',
      codePoint: Icons.breakfast_dining.codePoint,
    ),
    IconOption(
      iconData: Icons.bakery_dining,
      name: 'Bakery',
      codePoint: Icons.bakery_dining.codePoint,
    ),
    IconOption(
      iconData: Icons.icecream,
      name: 'Ice Cream',
      codePoint: Icons.icecream.codePoint,
    ),

    // Housing & Utilities
    IconOption(
      iconData: Icons.home,
      name: 'Home',
      codePoint: Icons.home.codePoint,
    ),
    IconOption(
      iconData: Icons.house,
      name: 'House',
      codePoint: Icons.house.codePoint,
    ),
    IconOption(
      iconData: Icons.apartment,
      name: 'Apartment',
      codePoint: Icons.apartment.codePoint,
    ),
    IconOption(
      iconData: Icons.bolt,
      name: 'Electricity',
      codePoint: Icons.bolt.codePoint,
    ),
    IconOption(
      iconData: Icons.water_drop,
      name: 'Water',
      codePoint: Icons.water_drop.codePoint,
    ),
    IconOption(
      iconData: Icons.thermostat,
      name: 'Heating',
      codePoint: Icons.thermostat.codePoint,
    ),
    IconOption(
      iconData: Icons.wifi,
      name: 'Internet',
      codePoint: Icons.wifi.codePoint,
    ),
    IconOption(
      iconData: Icons.phone,
      name: 'Phone',
      codePoint: Icons.phone.codePoint,
    ),
    IconOption(
      iconData: Icons.cleaning_services,
      name: 'Cleaning',
      codePoint: Icons.cleaning_services.codePoint,
    ),
    IconOption(
      iconData: Icons.build,
      name: 'Maintenance',
      codePoint: Icons.build.codePoint,
    ),

    // Transportation
    IconOption(
      iconData: Icons.directions_car,
      name: 'Car',
      codePoint: Icons.directions_car.codePoint,
    ),
    IconOption(
      iconData: Icons.local_gas_station,
      name: 'Gas',
      codePoint: Icons.local_gas_station.codePoint,
    ),
    IconOption(
      iconData: Icons.local_parking,
      name: 'Parking',
      codePoint: Icons.local_parking.codePoint,
    ),
    IconOption(
      iconData: Icons.directions_bus,
      name: 'Bus',
      codePoint: Icons.directions_bus.codePoint,
    ),
    IconOption(
      iconData: Icons.directions_subway,
      name: 'Subway',
      codePoint: Icons.directions_subway.codePoint,
    ),
    IconOption(
      iconData: Icons.train,
      name: 'Train',
      codePoint: Icons.train.codePoint,
    ),
    IconOption(
      iconData: Icons.local_taxi,
      name: 'Taxi',
      codePoint: Icons.local_taxi.codePoint,
    ),
    IconOption(
      iconData: Icons.two_wheeler,
      name: 'Motorcycle',
      codePoint: Icons.two_wheeler.codePoint,
    ),
    IconOption(
      iconData: Icons.pedal_bike,
      name: 'Bike',
      codePoint: Icons.pedal_bike.codePoint,
    ),
    IconOption(
      iconData: Icons.flight,
      name: 'Flight',
      codePoint: Icons.flight.codePoint,
    ),

    // Health & Fitness
    IconOption(
      iconData: Icons.local_hospital,
      name: 'Hospital',
      codePoint: Icons.local_hospital.codePoint,
    ),
    IconOption(
      iconData: Icons.medical_services,
      name: 'Medical',
      codePoint: Icons.medical_services.codePoint,
    ),
    IconOption(
      iconData: Icons.local_pharmacy,
      name: 'Pharmacy',
      codePoint: Icons.local_pharmacy.codePoint,
    ),
    IconOption(
      iconData: Icons.fitness_center,
      name: 'Gym',
      codePoint: Icons.fitness_center.codePoint,
    ),
    IconOption(
      iconData: Icons.sports_tennis,
      name: 'Sports',
      codePoint: Icons.sports_tennis.codePoint,
    ),
    IconOption(
      iconData: Icons.self_improvement,
      name: 'Wellness',
      codePoint: Icons.self_improvement.codePoint,
    ),
    IconOption(
      iconData: Icons.spa,
      name: 'Spa',
      codePoint: Icons.spa.codePoint,
    ),
    IconOption(
      iconData: Icons.favorite,
      name: 'Health',
      codePoint: Icons.favorite.codePoint,
    ),

    // Shopping & Personal
    IconOption(
      iconData: Icons.shopping_cart,
      name: 'Groceries',
      codePoint: Icons.shopping_cart.codePoint,
    ),
    IconOption(
      iconData: Icons.shopping_bag,
      name: 'Shopping',
      codePoint: Icons.shopping_bag.codePoint,
    ),
    IconOption(
      iconData: Icons.checkroom,
      name: 'Clothing',
      codePoint: Icons.checkroom.codePoint,
    ),
    IconOption(
      iconData: Icons.content_cut,
      name: 'Haircut',
      codePoint: Icons.content_cut.codePoint,
    ),
    IconOption(
      iconData: Icons.face,
      name: 'Beauty',
      codePoint: Icons.face.codePoint,
    ),
    IconOption(
      iconData: Icons.local_laundry_service,
      name: 'Laundry',
      codePoint: Icons.local_laundry_service.codePoint,
    ),

    // Entertainment
    IconOption(
      iconData: Icons.movie,
      name: 'Movies',
      codePoint: Icons.movie.codePoint,
    ),
    IconOption(
      iconData: Icons.theaters,
      name: 'Theater',
      codePoint: Icons.theaters.codePoint,
    ),
    IconOption(
      iconData: Icons.sports_esports,
      name: 'Gaming',
      codePoint: Icons.sports_esports.codePoint,
    ),
    IconOption(
      iconData: Icons.music_note,
      name: 'Music',
      codePoint: Icons.music_note.codePoint,
    ),
    IconOption(
      iconData: Icons.headphones,
      name: 'Audio',
      codePoint: Icons.headphones.codePoint,
    ),
    IconOption(iconData: Icons.tv, name: 'TV', codePoint: Icons.tv.codePoint),
    IconOption(
      iconData: Icons.videogame_asset,
      name: 'Video Games',
      codePoint: Icons.videogame_asset.codePoint,
    ),
    IconOption(
      iconData: Icons.park,
      name: 'Park',
      codePoint: Icons.park.codePoint,
    ),
    IconOption(
      iconData: Icons.beach_access,
      name: 'Beach',
      codePoint: Icons.beach_access.codePoint,
    ),

    // Education
    IconOption(
      iconData: Icons.school,
      name: 'School',
      codePoint: Icons.school.codePoint,
    ),
    IconOption(
      iconData: Icons.menu_book,
      name: 'Books',
      codePoint: Icons.menu_book.codePoint,
    ),
    IconOption(
      iconData: Icons.library_books,
      name: 'Library',
      codePoint: Icons.library_books.codePoint,
    ),
    IconOption(
      iconData: Icons.science,
      name: 'Science',
      codePoint: Icons.science.codePoint,
    ),
    IconOption(
      iconData: Icons.engineering,
      name: 'Engineering',
      codePoint: Icons.engineering.codePoint,
    ),

    // Technology
    IconOption(
      iconData: Icons.phone_android,
      name: 'Phone',
      codePoint: Icons.phone_android.codePoint,
    ),
    IconOption(
      iconData: Icons.computer,
      name: 'Computer',
      codePoint: Icons.computer.codePoint,
    ),
    IconOption(
      iconData: Icons.laptop,
      name: 'Laptop',
      codePoint: Icons.laptop.codePoint,
    ),
    IconOption(
      iconData: Icons.tablet,
      name: 'Tablet',
      codePoint: Icons.tablet.codePoint,
    ),
    IconOption(
      iconData: Icons.headset,
      name: 'Headset',
      codePoint: Icons.headset.codePoint,
    ),
    IconOption(
      iconData: Icons.camera,
      name: 'Camera',
      codePoint: Icons.camera.codePoint,
    ),
    IconOption(
      iconData: Icons.print,
      name: 'Printer',
      codePoint: Icons.print.codePoint,
    ),

    // Pets & Family
    IconOption(
      iconData: Icons.pets,
      name: 'Pets',
      codePoint: Icons.pets.codePoint,
    ),
    IconOption(
      iconData: Icons.child_care,
      name: 'Childcare',
      codePoint: Icons.child_care.codePoint,
    ),
    IconOption(
      iconData: Icons.toys,
      name: 'Toys',
      codePoint: Icons.toys.codePoint,
    ),
    IconOption(
      iconData: Icons.cake,
      name: 'Celebrations',
      codePoint: Icons.cake.codePoint,
    ),
    IconOption(
      iconData: Icons.card_giftcard,
      name: 'Gifts',
      codePoint: Icons.card_giftcard.codePoint,
    ),

    // Miscellaneous
    IconOption(
      iconData: Icons.payment,
      name: 'Bills',
      codePoint: Icons.payment.codePoint,
    ),
    IconOption(
      iconData: Icons.receipt,
      name: 'Receipt',
      codePoint: Icons.receipt.codePoint,
    ),
    IconOption(
      iconData: Icons.subscriptions,
      name: 'Subscriptions',
      codePoint: Icons.subscriptions.codePoint,
    ),
    IconOption(
      iconData: Icons.savings,
      name: 'Savings',
      codePoint: Icons.savings.codePoint,
    ),
    IconOption(
      iconData: Icons.trending_up,
      name: 'Investment',
      codePoint: Icons.trending_up.codePoint,
    ),
    IconOption(
      iconData: Icons.volunteer_activism,
      name: 'Charity',
      codePoint: Icons.volunteer_activism.codePoint,
    ),
    IconOption(
      iconData: Icons.work,
      name: 'Work',
      codePoint: Icons.work.codePoint,
    ),
    IconOption(
      iconData: Icons.category,
      name: 'Other',
      codePoint: Icons.category.codePoint,
    ),
  ];

  // Default fallback icons
  static final IconOption defaultAccountIcon = IconOption(
    iconData: Icons.account_balance,
    name: 'Bank',
    codePoint: Icons.account_balance.codePoint,
  );

  static final IconOption defaultPocketIcon = IconOption(
    iconData: Icons.folder,
    name: 'Folder',
    codePoint: Icons.folder.codePoint,
  );

  static final IconOption defaultCategoryIcon = IconOption(
    iconData: Icons.category,
    name: 'Category',
    codePoint: Icons.category.codePoint,
  );

  /// Check if icon codePoint is valid for accounts
  static bool isValidAccountIcon(int codePoint) {
    return accountIcons.any((icon) => icon.codePoint == codePoint);
  }

  /// Check if icon codePoint is valid for pockets
  static bool isValidPocketIcon(int codePoint) {
    // Allow any category icon for pockets (full icon library)
    return categoryIcons.any((icon) => icon.codePoint == codePoint);
  }

  /// Check if icon codePoint is valid for categories
  static bool isValidCategoryIcon(int codePoint) {
    return categoryIcons.any((icon) => icon.codePoint == codePoint);
  }

  /// Get IconData from codePoint for accounts
  static IconData getAccountIconData(int codePoint) {
    try {
      return accountIcons
          .firstWhere((icon) => icon.codePoint == codePoint)
          .iconData;
    } catch (e) {
      return defaultAccountIcon.iconData;
    }
  }

  /// Get IconData from codePoint for pockets
  static IconData getPocketIconData(int codePoint) {
    try {
      // Use category icons (full icon library) for pockets
      return categoryIcons
          .firstWhere((icon) => icon.codePoint == codePoint)
          .iconData;
    } catch (e) {
      return defaultPocketIcon.iconData;
    }
  }

  /// Get IconData from codePoint for categories
  static IconData getCategoryIconData(int codePoint) {
    try {
      return categoryIcons
          .firstWhere((icon) => icon.codePoint == codePoint)
          .iconData;
    } catch (e) {
      return defaultCategoryIcon.iconData;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../core/data/models/stain.dart';
import '../core/data/models/fabric.dart';
import '../core/data/models/product.dart';
import '../core/services/symbol_service.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('🚀 Starting to populate Firestore database...');

  // Clear existing data (optional - remove this in production)
  await _clearCollections(firestore);

  // Add sample stains
  await _addSampleStains(firestore);
  
  // Add sample fabrics
  await _addSampleFabrics(firestore);
  
  // Add sample products
  await _addSampleProducts(firestore);
  
  // Add care symbols
  await _addCareSymbols(firestore);

  print('✅ Database populated successfully!');
}

Future<void> _clearCollections(FirebaseFirestore firestore) async {
  print('🧹 Clearing existing collections...');
  
  final collections = ['stains', 'fabrics', 'products', 'care_symbols'];
  
  for (final collection in collections) {
    final snapshot = await firestore.collection(collection).get();
    final batch = firestore.batch();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('   Cleared $collection collection');
  }
}

Future<void> _addSampleStains(FirebaseFirestore firestore) async {
  print('🍷 Adding sample stains...');
  
  final stains = [
    Stain(
      id: 'wine_stain',
      name: 'Wine Stain',
      urgency: 'high',
      summary: 'Red wine stains are common and can be challenging to remove',
      byFabric: [
        StainByFabric(
          fabricId: 'cotton',
          stepsMd: '''
## How to Remove Wine Stains from Cotton

1. **Blot immediately** - Don't rub, just blot with a clean cloth
2. **Apply salt** - Cover the stain with table salt to absorb the wine
3. **Rinse with cold water** - Use cold water to prevent setting the stain
4. **Apply stain remover** - Use a commercial stain remover or white wine
5. **Wash normally** - Machine wash in cold water
          ''',
          recommendedProducts: ['stain_remover_spray', 'white_wine'],
          tipsMd: 'Act quickly - the faster you treat it, the better the results!',
        ),
      ],
      relatedProducts: ['stain_remover_spray', 'white_wine'],
      relatedFabrics: ['cotton', 'polyester'],
    ),
    Stain(
      id: 'coffee_stain',
      name: 'Coffee Stain',
      urgency: 'medium',
      summary: 'Coffee stains are acidic and can be removed with proper treatment',
      byFabric: [
        StainByFabric(
          fabricId: 'cotton',
          stepsMd: '''
## How to Remove Coffee Stains from Cotton

1. **Blot excess coffee** - Use a clean cloth to blot, don't rub
2. **Rinse with cold water** - Flush the stain from the back
3. **Apply vinegar solution** - Mix 1 part vinegar with 2 parts water
4. **Let it sit** - Allow the solution to work for 10-15 minutes
5. **Wash normally** - Machine wash in warm water
          ''',
          recommendedProducts: ['vinegar', 'stain_remover_spray'],
        ),
      ],
      relatedProducts: ['vinegar', 'stain_remover_spray'],
      relatedFabrics: ['cotton', 'polyester'],
    ),
    Stain(
      id: 'grease_stain',
      name: 'Grease Stain',
      urgency: 'high',
      summary: 'Grease stains require special treatment to break down the oils',
      byFabric: [
        StainByFabric(
          fabricId: 'cotton',
          stepsMd: '''
## How to Remove Grease Stains from Cotton

1. **Scrape off excess** - Remove any solid grease with a spoon
2. **Apply dish soap** - Use a small amount of dish soap directly on the stain
3. **Gently work in** - Use your fingers to work the soap into the fabric
4. **Let it sit** - Allow the soap to break down the grease for 15 minutes
5. **Wash in hot water** - Use the hottest water safe for the fabric
          ''',
          recommendedProducts: ['dish_soap', 'stain_remover_spray'],
        ),
      ],
      relatedProducts: ['dish_soap', 'stain_remover_spray'],
      relatedFabrics: ['cotton', 'polyester'],
    ),
  ];

  for (final stain in stains) {
    await firestore.collection('stains').doc(stain.id).set(stain.toFirestore());
    print('   Added stain: ${stain.name}');
  }
}

Future<void> _addSampleFabrics(FirebaseFirestore firestore) async {
  print('👕 Adding sample fabrics...');
  
  final fabrics = [
    Fabric(
      id: 'cotton',
      name: 'Cotton',
      image: 'assets/images/fabrics/cotton.jpg',
      overviewMd: '''
# Cotton Fabric Care

Cotton is a natural fiber that is comfortable, breathable, and easy to care for. It's one of the most popular fabrics for clothing and household items.

## Characteristics
- **Breathable** - Allows air to circulate
- **Absorbent** - Can hold up to 27 times its weight in water
- **Durable** - Strong and long-lasting
- **Easy to care for** - Can be machine washed and dried
      ''',
      stepsMd: '''
## How to Care for Cotton

1. **Washing** - Machine wash in warm or cold water
2. **Drying** - Can be tumble dried on medium heat
3. **Ironing** - Iron on high heat while damp
4. **Bleaching** - Can be safely bleached with chlorine bleach
      ''',
      commonStains: ['wine_stain', 'coffee_stain', 'grease_stain'],
      recommendedProducts: ['cotton_detergent', 'fabric_softener'],
    ),
    Fabric(
      id: 'polyester',
      name: 'Polyester',
      image: 'assets/images/fabrics/polyester.jpg',
      overviewMd: '''
# Polyester Fabric Care

Polyester is a synthetic fiber that is durable, wrinkle-resistant, and quick-drying. It's commonly used in sportswear and everyday clothing.

## Characteristics
- **Wrinkle-resistant** - Maintains its shape well
- **Quick-drying** - Dries faster than natural fibers
- **Durable** - Resistant to stretching and shrinking
- **Easy care** - Low maintenance fabric
      ''',
      stepsMd: '''
## How to Care for Polyester

1. **Washing** - Machine wash in warm water
2. **Drying** - Tumble dry on low heat
3. **Ironing** - Iron on low heat if needed
4. **Bleaching** - Avoid chlorine bleach
      ''',
      commonStains: ['grease_stain', 'ink_stain'],
      recommendedProducts: ['synthetic_detergent'],
    ),
  ];

  for (final fabric in fabrics) {
    await firestore.collection('fabrics').doc(fabric.id).set(fabric.toFirestore());
    print('   Added fabric: ${fabric.name}');
  }
}

Future<void> _addSampleProducts(FirebaseFirestore firestore) async {
  print('🧴 Adding sample products...');
  
  final products = [
    Product(
      id: 'stain_remover_spray',
      name: 'Stain Remover Spray',
      image: 'assets/images/products/stain_remover.jpg',
      subtitle: 'Powerful formula for tough stains',
      ingredientsMd: '''
## Ingredients

- **Enzymes** - Break down protein-based stains
- **Surfactants** - Help lift stains from fabric
- **Solvents** - Dissolve oil-based stains
- **Water** - Base solution
      ''',
      howToUseMd: '''
## How to Use

1. **Test first** - Test on a hidden area
2. **Apply directly** - Spray directly on the stain
3. **Let it work** - Allow 5-10 minutes to penetrate
4. **Wash normally** - Machine wash as usual
      ''',
      allergenFlags: [],
      removesStains: ['wine_stain', 'coffee_stain', 'grease_stain'],
      fitsFabrics: ['cotton', 'polyester'],
      affiliateUrl: 'https://amazon.com/stain-remover-spray',
    ),
    Product(
      id: 'white_wine',
      name: 'White Wine',
      image: 'assets/images/products/white_wine.jpg',
      subtitle: 'Natural stain remover for red wine',
      ingredientsMd: '''
## Ingredients

- **White wine** - Contains tannins that help remove red wine stains
- **Alcohol** - Helps break down the stain
      ''',
      howToUseMd: '''
## How to Use

1. **Pour white wine** - Pour white wine directly on the red wine stain
2. **Blot gently** - Use a clean cloth to blot
3. **Rinse with cold water** - Flush with cold water
4. **Wash normally** - Machine wash as usual
      ''',
      allergenFlags: ['alcohol'],
      removesStains: ['wine_stain'],
      fitsFabrics: ['cotton', 'polyester'],
      affiliateUrl: 'https://amazon.com/white-wine',
    ),
  ];

  for (final product in products) {
    await firestore.collection('products').doc(product.id).set(product.toFirestore());
    print('   Added product: ${product.name}');
  }
}

Future<void> _addCareSymbols(FirebaseFirestore firestore) async {
  print('🏷️ Adding care symbols...');
  
  final symbolService = SymbolService();
  final symbols = symbolService.symbols;

  for (final symbol in symbols) {
    await firestore.collection('care_symbols').doc(symbol.id).set(symbol.toFirestore());
    print('   Added symbol: ${symbol.name}');
  }
}

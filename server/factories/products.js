Fake.reactionMetaField = function(params) {
  params = params || {};
  return {
    key: params.key ? params.key : Fake.word(),
    value: params.value ? params.value : Fake.sentence(),
    scope: params.scope ? params.scope : 'detail'
  };
};

Fake.reactionProductVariant = function(params) {
  params = params || {};
  defaultValues = {
    _id: Random.id(),
    compareAtPrice: _.random(0, 1000),
    weight: _.random(0, 10),
    inventoryManagement: true,
    inventoryPolicy: false,
    lowInventoryWarningThreshold: 1,
    inventoryQuantity: _.random(0, 100),
    price: _.random(10, 1000),
    optionTitle: Fake.word(),
    title: Fake.word(),
    sku: _.random(0, 6),
    taxable: true,
    metafields: [
      Fake.reactionMetaField(),
      Fake.reactionMetaField({key: 'facebook', scope: 'socialMessages'}),
      Fake.reactionMetaField({key: 'twitter', scope: 'socialMessages'})
    ]
  };
  return _.extend(defaultValues, params);
};

Fake.reactionProductInventoryVariant = function(params) {
  params = params || {};
  defaultValues = {
    _id: Random.id(),
    barcode: _.random(100000,999999), //Random 6 Digit Barcode
    parentId: Random.id(),
    type: 'inventory'
  };
  return _.extend(defaultValues, params);
};

// Setup some fake ids to be shared among parent and child variants.
sharedId1 = Random.id();
sharedId2 = Random.id();
sharedId3 = Random.id();

Factory.define('product', ReactionCore.Collections.Products, {
  shopId: Factory.get('shop'),
  title: Fake.word,
  pageTitle: Fake.sentence(5),
  description: Fake.paragraph(20),
  productType: Fake.sentence(2),
  vendor: '',
  metafields: [],
  variants: [
    Fake.reactionProductVariant()
  ],
  requiresShipping: true,
  // parcel: ?,
  hashtags: [],
  // twitterMsg: ?,
  // facebookMsg: ?,
  // googleplusMsg: ?,
  // pinterestMsg: ?,
  // metaDescription: ?,
  // handle: ?,
  isVisible: false,
  publishedAt: new Date(),
  // publishedScope: ?,
  // templateSuffix: ?,
  createdAt: new Date(),
  updatedAt: new Date()
});

Factory.define('productWithChildVariants', ReactionCore.Collections.Products,
  Factory.extend('product', {
    variants: function() {
      return [
        // Parent Variant - variants[0]
        Fake.reactionProductVariant({_id: sharedId1}),
        // Child Variants - variants[1..8]
        Fake.reactionProductVariant({parentId: sharedId1}),
        Fake.reactionProductVariant({parentId: sharedId1}),
        Fake.reactionProductVariant({parentId: sharedId1}),
        Fake.reactionProductVariant({parentId: sharedId1}),
        Fake.reactionProductVariant({parentId: sharedId1}),
        Fake.reactionProductVariant({parentId: sharedId1}),
        Fake.reactionProductVariant({parentId: sharedId1}),
        // Child Variant w/ Children variants[8]
        Fake.reactionProductVariant({
          _id: sharedId2,
          parentId: sharedId1
        }),
        // Grandchildren variants - variants[9..11]
        Fake.reactionProductVariant({parentId: sharedId2}),
        Fake.reactionProductVariant({parentId: sharedId2}),
        Fake.reactionProductVariant({parentId: sharedId2})
      ];
    }
  }));

Factory.define('productWithInventoryVariants', ReactionCore.Collections.Products,
  Factory.extend('product', {
    variants: function() {
      return [
        // Parent Variant - variants[0]
        Fake.reactionProductVariant({_id: sharedId1}),
        // Child Variants - variants[1..2]
        Fake.reactionProductVariant({parentId: sharedId1}),
        Fake.reactionProductVariant({parentId: sharedId1}),
        // Child Variant w/ inventory - variants[3]
        Fake.reactionProductVariant({
          _id: sharedId2,
          parentId: sharedId1
        }),
        // inventory variants - variants[4..13]
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2}),
        Fake.reactionProductInventoryVariant({parentId: sharedId2})
      ];
    }
  }));

Factory.define('tag', ReactionCore.Collections.Tags, {
  name: Fake.word,
  slug: Fake.word,
  position: _.random(0, 100000),
  //  relatedTagIds: [],
  isTopLevel: true,
  shopId: Factory.get('shop'),
  createdAt: new Date(),
  updatedAt: new Date()
});

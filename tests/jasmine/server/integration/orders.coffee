describe 'getoutfitted:reaction-rental-products orders methods', ->
  describe 'inventoryAdjust', ->
    beforeEach ->
      Products.remove {}
      Orders.remove {}
      
    it 'should adjust inventory on completed order', (done) ->
      product = Factory.create 'product'
      variant = product.variants[0]
      quantity = 1
      
      order = Factory.create 'order', {
        items: [
          _id: Random.id()
          productId: product._id
          variants: variant
          quantity: quantity
        ]
      }
      
      preInventoryAvailable = variant.inventoryQuantity
      
      Meteor.call 'inventoryAdjust', order._id
      
      product = Products.findOne(product._id)
      variant = product.variants[0]
      
      postInventoryAvailable = variant.inventoryQuantity
      expect(postInventoryAvailable + quantity).toEqual(
        preInventoryAvailable)

      done()

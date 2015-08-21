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

  describe 'addTracking', ->
    beforeEach ->
      Orders.remove {}
    
    it 'should add a tracking number to the order', (done) ->
      order = Factory.create 'order'
      expect(order.shipping.shipmentMethod.tracking).toBeFalsy
      
      Meteor.call 'addTracking', order._id, '1Z9999999999999999'
      
      order = Orders.findOne(order._id)
      tracking = order.shipping.shipmentMethod.tracking
      expect(tracking).toEqual('1Z9999999999999999')

      done()
      
    it 'should not change other fields in the order', (done) ->
      order = Factory.create 'order'
      expect(order.shipping.shipmentMethod.tracking).toBeFalsy
      
      Meteor.call 'addTracking', order._id, '1Z9999999999999999'
      
      updatedOrder = Orders.findOne(order._id)
      tracking = updatedOrder.shipping.shipmentMethod.tracking

      # add tracking number to original order
      order.shipping.shipmentMethod.tracking = '1Z9999999999999999'
      # normalize updatedAt fields
      order.updatedAt = updatedOrder.updatedAt
      # check to make sure objects are identical otherwise
      expect(_.isEqual(order, updatedOrder)).toBeTrue
      done()
            
    it 'should throw an error if orderId is not a String', (done) ->
      order = Factory.create 'order'
      expect(-> Meteor.call 'addTracking', 9, '1Z9999999999999999').toThrow
      done()
      
  describe 'addOrderEmail', ->
    beforeEach ->
      Orders.remove {}
    
    it 'should add an email to the order', (done) ->
      order = Factory.create 'order'
      expect(order.email).toBeFalsy
      
      Meteor.call 'addOrderEmail', order._id, 'example@example.com'
      order = Orders.findOne(order._id)
      
      expect(order.email).toEqual 'example@example.com'
      done()

    # this is expensive due to checking object equivalence
    it 'should not change other fields when updating the email', (done) ->
      order = Factory.create 'order'
      expect(order.shipping.shipmentMethod.tracking).toBeFalsy
      
      Meteor.call 'addOrderEmail', order._id, 'example@example.com'
      
      updatedOrder = Orders.findOne(order._id)
      email = updatedOrder.email

      # add tracking number to original order
      order.email = 'example@example.com'
      # normalize updatedAt fields
      order.updatedAt = updatedOrder.updatedAt
      # check to make sure objects are identical otherwise
      expect(_.isEqual(order, updatedOrder)).toBeTrue
      done()
          
    it 'should throw an error if orderId is not a String', (done) ->
      order = Factory.create 'order'
      expect(-> Meteor.call 'addOrderEmail', 9, 'example@example.com').toThrow
      done()
      
describe 'updateWorkflow', ->
  beforeEach ->
    Orders.remove {}
  
  it 'should add update the state of the order', (done) ->
    spyOn(Meteor, "userId").and.callFake(-> Random.id())
    
    order = Factory.create 'order'
    expect(order.state).toEqual 'new'
    
    Meteor.call 'updateWorkflow', order._id, 'In Transit'
    order = Orders.findOne(order._id)
    
    expect(order.state).toEqual 'In Transit'
    done()
    
    expect(order.history.length).toEqual 1
    expect(order.history[0].event).toEqual 'In Transit'
        
  it 'should throw an error if orderId is not a String', (done) ->
    order = Factory.create 'order'
    expect(-> Meteor.call 'updateWorkflow', {}, 'In Transit').toThrow
    
    expect(order.history.length).toEqual 0
    done()



describe 'updateDocuments', ->
  beforeEach ->
    Orders.remove {}
  
  #
  # Negative Tests - Test for passing bad or non-existant values
  # to updateDocuments
  #
  it 'should throw an error if orderId does not exist', (done) ->
    expect(-> Meteor.call(
      'updateDocuments')).toThrow
    done()
    
  it 'should throw an error if orderId is not a string', (done) ->
    randomId = Random.id()
    order = Factory.create 'order'
    
    expect(-> Meteor.call(
      'updateDocuments', ['123'], randomId, 'packing slip')).toThrow
    done()
    
  it 'should throw an error if docId does not exist', (done) ->
    randomId = Random.id()
    order = Factory.create 'order'
    
    expect(-> Meteor.call(
      'updateDocuments', order._id)).toThrow
    done()
    
  it 'should throw an error if docId is not a string', (done) ->
    randomId = Random.id()
    order = Factory.create 'order'
    
    expect(-> Meteor.call(
      'updateDocuments', order._id, 12345, 'packing slip')).toThrow
    done()
    
  it 'should throw an error if docType does not exist', (done) ->
    randomId = Random.id()
    order = Factory.create 'order'

    expect(-> Meteor.call(
      'updateDocuments', order._id, randomId)).toThrow
    done()

  it 'should throw an error if docType is not a string', (done) ->
    randomId = Random.id()
    order = Factory.create 'order'

    expect(-> Meteor.call(
      'updateDocuments', order._id, randomId, {'key': 'val'})).toThrow
    done()
  
  #
  # Positive Tests - make sure that updateDocuments works as intended
  #
  it 'should add document to order', (done) ->
    randomId = Random.id()
    order = Factory.create 'order'
    expect(order.documents).toBeEmpty
  
    Meteor.call 'updateDocuments', order._id, randomId, 'Return Label'
  
    order = Orders.findOne(order._id)
  
    expect(order.documents).not.toBeEmpty
    expect(order.documents[0].docId).toEqual randomId
    expect(order.documents[0].docType).toEqual 'Return Label'
    done()

#
#
#
describe 'updateHistory', ->
  beforeEach ->
    Orders.remove {}
    
  #
  # Negative Tests - Test for passing bad or non-existant values
  # to updateHistory
  #
  it 'should throw an error if orderId does not exist', (done) ->
    expect(-> Meteor.call(
      'updateHistory')).toThrow
    done()
    
  it 'should throw an error if orderId is not a string', (done) ->
    order = Factory.create 'order'
    
    expect(-> Meteor.call(
      'updateHistory', ['123'], 'an event')).toThrow
    done()
    
  it 'should throw an error if event does not exist', (done) ->
    order = Factory.create 'order'
    
    expect(-> Meteor.call(
      'updateHistory', order._id)).toThrow
    done()
    
  it 'should throw an error if event is not a string', (done) ->
    order = Factory.create 'order'
    
    expect(-> Meteor.call(
      'updateHistory', order._id, {event: 'an event'})).toThrow
    done()
    
  it 'should throw an error if value is not a string', (done) ->
    order = Factory.create 'order'

    expect(-> Meteor.call(
      'updateHistory', order._id, 'an event', {'key': 'val'})).toThrow
    done()
  
  #
  # Positive Tests - make sure that updateHistory works as intended
  #
  it 'should add document to order by passing an
    orderId, event, and value', (done) ->
      
    spyOn(Meteor, "userId").and.callFake(-> Random.id())

    order = Factory.create 'order'
    expect(order.history).toBeEmpty
  
    Meteor.call 'updateHistory', order._id, 'an event', 'event value'
  
    order = Orders.findOne(order._id)
    
    expect(order.history).not.toBeEmpty
    expect(order.history[0].event).toEqual 'an event'
    expect(order.history[0].value).toEqual 'event value'
    done()
    
  it 'should add document to order by passing an
    orderId and event', (done) ->
    
    spyOn(Meteor, "userId").and.callFake(-> Random.id())

    order = Factory.create 'order'
    expect(order.history).toBeEmpty
  
    Meteor.call 'updateHistory', order._id, 'an event'
  
    order = Orders.findOne(order._id)
  
    expect(order.history).not.toBeEmpty
    expect(order.history[0].event).toEqual 'an event'
    expect(order.history[0].value).toEqual undefined
    done()


describe 'processPayments', ->
  beforeEach ->
    Orders.remove {}
  
  it 'should throw an error if called without an OrderId', (done) ->
    expect(-> Meteor.call('processPayments')).toThrow
    done()
  
  it 'should process a payment if payment mode
    is authorize and status is approved', (done) ->
    order = Factory.create 'authorizedApprovedPaypalOrder'
    
    spyOn(Meteor['Paypal'], 'capture').and.returnValue(
      {capture: {id: Random.id()}})
      
    Meteor.call 'processPayments', order._id
    done()
    

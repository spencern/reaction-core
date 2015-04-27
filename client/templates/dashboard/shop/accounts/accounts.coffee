Template.shopAccounts.rendered = ->
  $(document).foundation('reveal', 'reflow');

Template.shopAccounts.helpers
  members: () ->
    return Shops.findOne()?.members

Template.shopAccounts.events
  "click #button-add-member": (event,template) ->
    $('#member-form').foundation('reveal', 'open')

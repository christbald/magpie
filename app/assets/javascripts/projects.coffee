# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

niceSelectUpdate = ->
  # enable chosen js
  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '100%'

selectModel = ->

  if $('#project_model_id').find(":selected").text() != ""

    if document.getElementById 'model_info_sync'
      model_id = $('#project_model_id').find(":selected")[0].value
      $.ajax
        # url has to be modified, in order to update the right job according to the id
        async: true
        url: "/project_modeldescription?model_id="+model_id
        cache: true
        success: (html) ->
          #console.log html
          document.getElementById('model_info_sync').innerHTML = html

    if document.getElementById 'project_modelconfig'
      model_id = $('#project_model_id').find(":selected")[0].value
      model_revision = "HEAD"
      $.ajax
        async: true
        url: "/project_modelconfig?model_id="+model_id+"&model_revision="+model_revision
        cache: true
        success: (html) ->
          #console.log html
          document.getElementById('project_modelconfig').innerHTML = html
          #$('input[type=file]').bootstrapFileInput()
          $('.file-inputs-model-config').bootstrapFileInput()

     if document.getElementById 'project_modelrevisions'
       model_id = $('#project_model_id').find(":selected")[0].value
       $.ajax
         async: true
         url: "/project_modelrevisions?model_id="+model_id
         cache: true
         success: (html) ->
           #console.log html
           document.getElementById('project_modelrevisions').innerHTML = html
           niceSelectUpdate();

selectRevision = ->

  if $('#project_model_id').find(":selected").text() != ""

    if document.getElementById 'project_modelconfig'
      model_id = $('#project_model_id').find(":selected")[0].value
      model_revision = $('#config_revision').find(":selected").text()
      $.ajax
        async: true
        url: "/project_modelconfig?model_id="+model_id+"&model_revision="+model_revision
        cache: true
        success: (html) ->
          #console.log html
          document.getElementById('project_modelconfig').innerHTML = html


changeModel = -> if document.getElementById 'project_model_id'
  document.getElementById('project_model_id').onchange = selectModel

changeRevision = -> if document.getElementById 'project_modelrevisions'
  document.getElementById('project_modelrevisions').onchange = selectRevision


changeToggleButton = ->
  $('#project_public').bootstrapToggle();

noPropagate = ->
  $('.dont-propagate-in-project-a-href').click (event) ->
    event.stopPropagation();

# ---
# generated by js2coffee 2.2.0

$( document ).on('turbolinks:load', selectModel)
$( document ).on('turbolinks:load', changeModel)
$( document ).on('turbolinks:load', changeRevision)
$( document ).on('turbolinks:load', changeToggleButton)
$( document ).on('turbolinks:load', noPropagate)

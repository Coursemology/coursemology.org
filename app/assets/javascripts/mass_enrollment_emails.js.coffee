# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

clearFileInput = ()->
  fileInput = $('#cvs_file')
  fileInput.replaceWith(fileInput = fileInput.clone(true))
  $('#emails-tbody').empty()

readSingleFile = (evt)->
  f = evt.target.files[0]
  if f
    r = new FileReader()
    r.onload = ()->
      contents = r.result
      parseContacts(contents)
    r.readAsText(f)
  else
    alert "Failed to load file"

parseContacts = (contents)->
  error_msg = "File content format not valid!"
  raw_list = []
  raw_list.push row.trim() for row in contents.split('\n')
  if raw_list.length == 0
    alert error_msg
    return false

  header = raw_list[0].split(',')
  header = (item.toLowerCase().trim() for item in header)
  nameIndex = header.indexOf('name')

  if header.length == 0 or nameIndex < 0
    alert error_msg
    return false


  emailHeaders = ['E-mail 1 - Value'.toLowerCase(),'E-mail'.toLowerCase(), 'email']
  emailIndex = header.indexOf(val) for val in emailHeaders when header.indexOf(val) >= 0


  if emailIndex == undefined
    alert "Can't find email field in the file"
    return false
  contacts = []
  contacts.push {name: row.split(',')[nameIndex].trim(), email: row.split(',')[emailIndex].trim()} for row in raw_list[1..(raw_list.length - 1)] when row.split(',')[emailIndex] != undefined
  console.log(contacts)

  $('#emails-tbody').append "<tr><td><input type='checkbox' class='checkbox-emails' checked/></td><td class='name'>#{contact.name}</td><td class='email'>#{contact.email}</td></tr>" for contact in contacts

  $('#emails-to-invite-modal').modal('toggle')

sendInvitationCVS = ()->
  target = $('.check-all-emails').attr('data-target');
  selected_cbs = $.grep($(target), (cb)-> $(cb).prop('checked'))
  selected_rows = $.map($(selected_cbs), (cb)-> $(cb).parents('tr'))
  selected_stds = []
  selected_stds.push {name: row.find('.name').html(), email: row.find('.email').html()} for row in selected_rows
  postToServer(selected_stds)

@sendInvitationTable = ()->
  rows = $('#tbody-add-student tr')
  entered_stds = []
  entered_stds.push {name: $(row).find('.name').val(), email: $(row).find('.email').val() } for row in rows

  postToServer(entered_stds)

updateSelected = (evt)->
  evt.preventDefault()
  url = $(this).attr('href')
  target = $(this).attr('data-target')
  selected_cb = $.grep($(target), (cb)-> $(cb).prop('checked') )
  selected_ids = $.map($(selected_cb), (cb)-> $(cb).val() )
  if selected_ids.length == 0
    alert("No student selected!")
    return

  $.ajax({
    url: url,
    type: 'POST',
    data: { students: selected_ids },
    dataType: 'json',
    success: (e)-> location.reload()
  })


postToServer = (selected_stds)->
  url = $('#email-invitation-url').val()

  $.ajax({
    url: url,
    type: 'POST',
    data: { students: selected_stds },
    dataType: 'json',
    success: (e)-> location.reload()
  })


@stdRemoveRow = (row) ->
  $(row).remove()
  if $('#tbody-add-student tr').length == 0
     $('#add-student-table').remove()

addStudent = ()->
  if $('#tbody-add-student').length == 0
    $('#add-student-div').append('
        <table class="table table-bordered"  id="add-student-table">
          <thead><tr>
            <td>Name</td>
            <td>Email</td>
            <td></td>
          </tr></thead>
          <tbody id="tbody-add-student">
          </tbody>
          <tfoot id="add-student-footer">
          <tr>
           <td colspan="3" style="text-align: right">
            <a href="#" class="btn btn-primary" id="send-invitation-emails-table" onclick="sendInvitationTable()">Send Invitation Emails</a>
          </td>
          </tr>
          </tfoot>
         </table>')

  $('#tbody-add-student').append('<tr><td><input type="text" class="name"/></td><td><input type="email" class="email"></td><td><a  title="Delete this test" class = "btn" onclick="stdRemoveRow(this.parentNode.parentNode)"><i class="icon-remove"></i> </a></td></tr>')

$(document).ready ->
  $('#cvs_file').change(readSingleFile)
  $('#emails-to-invite-modal').on('hidden', clearFileInput)
  $('.check-all-emails').change(() ->
    val = $(this).prop('checked')
    target = $(this).attr('data-target')
    $(target).prop('checked', val)
  )
  $('#send-invitation-emails').click(sendInvitationCVS)
  $('#manually-add-student').click(addStudent)
  $('.invite-update-selected').click(updateSelected)

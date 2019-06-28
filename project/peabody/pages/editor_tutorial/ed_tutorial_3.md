# Commands

Use the tool's commands navigate the interview's audio and transcript. These commands are available in the toolbar along the bottom of the screen and with the following keyboard shortcuts.

<table class="table-commands">
    <% _.each(project.controls, function(control) { %>
    <tr>
        <td><%= control.keyLabel %></td>
        <td><%= control.keyDescription %></td>
    </tr>
    <% }) %>
</table>

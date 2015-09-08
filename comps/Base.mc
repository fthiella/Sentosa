<%class>
has 'title';
has '_app';
</%class>

<%augment wrap><!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
% $.Defer {{
    <title><% $.title %></title>
% }}

<& head_includes.mi &>
</head>

<body>
<& body_includes.mi &>

    <div id="wrapper">

        <!-- Navigation -->
        <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
% $.Defer {{
              <& widgets/navbar_header.mi, caption=>$.title &>
% }}
            <ul class="nav navbar-top-links navbar-right">
              <& widgets/dropdown_tasks.mc &>
              <& widgets/dropdown_messages.mc &>
              <& widgets/dropdown_alerts.mc &>
              <& widgets/dropdown_user.mi &>
            </ul>
            <& /widgets/sidebar.mc, _app => $._app &>

            <!-- /.navbar-static-side -->
        </nav>

        <div id="page-wrapper">
            <% inner() %>
        </div>
        <!-- /#page-wrapper -->

    </div>
    <!-- /#wrapper -->

</body>
</html>
</%augment>
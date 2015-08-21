<%class>
has 'title';
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

    <!-- Bootstrap Core CSS -->
    <link href="/static/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- MetisMenu CSS -->
    <link href="/static/bower_components/metisMenu/dist/metisMenu.min.css" rel="stylesheet">
    
    <!-- DataTables CSS -->
    <link href="/static/bower_components/datatables-plugins/integration/bootstrap/3/dataTables.bootstrap.css" rel="stylesheet">

    <!-- DataTables Responsive CSS -->
    <link href="/static/bower_components/datatables-responsive/css/dataTables.responsive.css" rel="stylesheet">

    <!-- Timeline CSS -->
    <link href="/static/dist/css/timeline.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="/static/dist/css/sb-admin-2.css" rel="stylesheet">

    <!-- Morris Charts CSS -->
    <link href="/static/bower_components/morrisjs/morris.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="/static/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

</head>

<body>
    <!-- jQuery -->
    <script src="/static/bower_components/jquery/dist/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="/static/bower_components/bootstrap/dist/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="/static/bower_components/metisMenu/dist/metisMenu.min.js"></script>

    <!-- Morris Charts JavaScript -->
    <script src="/static/bower_components/raphael/raphael-min.js"></script>
    <script src="/static/bower_components/morrisjs/morris.min.js"></script>
    <!-- DISABLED <script src="/static/js/morris-data.js"></script> -->

    <!-- Custom Theme JavaScript -->
    <script src="/static/dist/js/sb-admin-2.js"></script>

    <!-- DataTables JavaScript -->
    <script src="/static/bower_components/datatables/media/js/jquery.dataTables.min.js"></script>
    <script src="/static/bower_components/datatables-plugins/integration/bootstrap/3/dataTables.bootstrap.min.js"></script>

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
              <& widgets/dropdown_user.mi, user=>Sentosa::Users::get_userinfo($.authenticated_user) || 'Guest' &>
            </ul>
            <& /widgets/sidebar.mc, authenticated_user => $.authenticated_user &>

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
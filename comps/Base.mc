<%class>
has 'title';
</%class>

###################################################################################################
<%method navbar_header ($caption)>
<div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="index.html"><% $caption %></a>
</div>
</%method>
###################################################################################################
<%method dropdown_messages ($items) >
<li class="dropdown">
  <a class="dropdown-toggle" data-toggle="dropdown" href="#">
    <i class="fa fa-envelope fa-fw"></i>  <i class="fa fa-caret-down"></i>
  </a>
  <ul class="dropdown-menu dropdown-messages">
% foreach my $item (@$items) {
<li>
    <a href="#">
      <div>
        <strong><% $item->{from} %></strong>
        <span class="pull-right text-muted">
          <em><% $item->{when} %></em>
        </span>
        </div>
      <div><% $item->{msg} %></div>
    </a>
</li>
<li class="divider"></li>
% }
    <li>
      <a class="text-center" href="#">
      <strong>Read All Messages</strong>
      <i class="fa fa-angle-right"></i>
      </a>
    </li>
  </ul>
</li>
</%method>
###################################################################################################
<%method dropdown_tasks ($items) >
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <i class="fa fa-tasks fa-fw"></i>  <i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-tasks">
% foreach my $item (@$items) {
                        <li>
                            <a href="#">
                                <div>
                                    <p>
                                        <strong><% $item->{task} %></strong>
                                        <span class="pull-right text-muted"><% $item->{complete} %>% Complete</span>
                                    </p>
                                    <div class="progress progress-striped active">
                                        <div class="progress-bar <% $item->{bar} %>" role="progressbar" aria-valuenow="<% $item->{complete} %>" aria-valuemin="0" aria-valuemax="100" style="width: <% $item->{complete} %>%">
                                            <span class="sr-only"><% $item->{complete} %>% Complete (success)</span>
                                        </div>
                                    </div>
                                </div>
                            </a>
                        </li>
                        <li class="divider"></li>
% }
                        <li>
                            <a class="text-center" href="#">
                                <strong>See All Tasks</strong>
                                <i class="fa fa-angle-right"></i>
                            </a>
                        </li>
                    </ul>
                </li>
</%method>
###################################################################################################
<%method dropdown_alerts ($items) >
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <i class="fa fa-bell fa-fw"></i>  <i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-alerts">
% foreach my $item (@$items) {
                        <li>
                            <a href="#">
                                <div>
                                    <i class="fa <% $item->{type} %> fa-fw"></i> <% $item->{notification} %>
                                    <span class="pull-right text-muted small"><% $item->{when} %></span>
                                </div>
                            </a>
                        </li>
                        <li class="divider"></li>
% }
                        <li>
                            <a class="text-center" href="#">
                                <strong>See All Alerts</strong>
                                <i class="fa fa-angle-right"></i>
                            </a>
                        </li>
                    </ul>
</%method>
###################################################################################################
<%method dropdown_user ($user) >
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <i class="fa fa-user fa-fw"></i> <% $user %> <i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-user">
                        <li><a href="#"><i class="fa fa-user fa-fw"></i> User Profile</a>
                        </li>
                        <li><a href="#"><i class="fa fa-gear fa-fw"></i> Settings</a>
                        </li>
                        <li class="divider"></li>
                        <li><a href="/?logout"><i class="fa fa-sign-out fa-fw"></i> Logout</a>
                        </li>
                    </ul>
                    <!-- /.dropdown-user -->
                </li>
</%method>
<%method sidebar_no ($items)>
            <div class="navbar-default sidebar" role="navigation">
                <div class="sidebar-nav navbar-collapse">
                    <ul class="nav" id="side-menu">
% foreach my $item (@$items) {
                        <li>
                            <a href="<% $item->{url} %>"><i class="fa <% $item->{type} %> fa-fw"></i> <% $item->{title} %>
%   if (defined $item->{second}) {
                            <span class="fa arrow"></span>
%   }
                            </a>
%   if (defined $item->{second}) {
                            <ul class="nav nav-second-level">
%     foreach my $second (@{$item->{second}}) {
                                <li>
                                    <a href="<% $second->{url} %>"><% $second->{title} %></a>
                                </li>
%     }
                            </ul>
%   }
                        </li>
% }
                    </ul>
                </div>
                <!-- /.sidebar-collapse -->
            </div>
</%method>

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

    <div id="wrapper">

        <!-- Navigation -->
        <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
% $.Defer {{
            <% $.navbar_header($.title) %>
% }}

            <ul class="nav navbar-top-links navbar-right">
                <% $.dropdown_messages(
                   [
                     {from=>'Federico', when=>'Yesterday', msg=>'This is my message from yesterday'},
                     {from=>'Joy', when=>'Yesterday', msg=>'Joy wrote you something'},
                   ]) %>

                <% $.dropdown_tasks(
                    [
                      {task=>'Export', complete=>40, bar=>'progress-bar-success'},
                      {task=>'Normalize data', complete=>20, bar=>'progress-bar-danger'},
                    ]) %>
                
                <% $.dropdown_alerts(
                    [
                      {type=>'fa-comment', notification=>'New Comment', when=>'4 minutes ago'},
                      {type=>'fa-twitter', notification=>'3 New Followers', when=>'7 minutes ago'},
                      {type=>'fa-envelope', notification=>'Message Sent', when=>'12 minutes ago'},
                      {type=>'fa-tasks', notification=>'New Task', when=>'5 minutes ago'},
                      {type=>'fa-upload', notification=>'Server Rebooted', when=>'15 minutes ago'},
                    ]) %>
                
                <% $.dropdown_user( Sentosa::Users::get_userinfo($.authenticated_user) || 'Guest' ) %>

                <!-- /.dropdown -->
            </ul>
            <!-- /.navbar-top-links -->
            
            <& sidebar.mas, items=>
                [
                  {type=>'fa-dashboard', title=>'Dashboard', url=>''},
                  {type=>'fa-bar-chart-o', title=>'Charts', url=>'',
                    second=>[
                      {title=>'Flot Charts', url=>'flot.html'},
                      {title=>'Morris Charts', url=>'morris.html'},                      
                    ]
                  },
                  {type=>'fa-table', title=>'Tables', url=>''},
                  {type=>'fa-edit', title=>'Forms', url=>''},
            
                ] &>
            <!-- /.navbar-static-side -->
        </nav>

        <div id="page-wrapper">
            <% inner() %>
        </div>
        <!-- /#page-wrapper -->

    </div>
    <!-- /#wrapper -->

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

</body>
</html>
</%augment>
<%class>
</%class>

<h2>Welcome to <% Sentosa::Utils::get_appinfo %></h2>

<hr>

<p>
You are logged in as <% Sentosa::Users::get_userinfo($.authenticated_user) || 'Guest' %>.
</p>
<p>
Your groups are:
<ul>
% foreach my $group (Sentosa::Users::get_groupsuserinfo($.authenticated_user)) {
  <li><% $group->{groupname} %></li>
% }
</ul>
</p>
Your apps are:
<ul>
% foreach my $app (Sentosa::Users::get_appsuserinfo($.authenticated_user)) {
  <li><% $app->{url} %></li>
% }
</ul>
<hr>

<a href="">Reload this page!</a> or
<a href="?logout">Logout</a>
<%init>
  use Sentosa::Utils;
  use Data::Dumper;

  $.title('Welcome to '.Sentosa::Utils::get_appinfo);
</%init>
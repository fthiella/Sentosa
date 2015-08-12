<%class>
</%class>
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

<p>
  <form action="" method="post">
    username: <input type=text name=username>
    password: <input type=password name=password>
    <input type=submit>
  </form>
</p>
<%init>
  use Sentosa::Utils;
  use Data::Dumper;

  $.title(Sentosa::Utils::get_appinfo);
</%init>
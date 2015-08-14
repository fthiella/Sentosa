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

<a href="login">Go to login page!</a>
<%init>
  use Sentosa::Utils;
  use Data::Dumper;

  $.title(Sentosa::Utils::get_appinfo);
</%init>
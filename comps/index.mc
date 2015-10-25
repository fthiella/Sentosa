<%class>
</%class>
<h1>Welcome to Sentosa Autoforms</h1>
<img src="/static/images/cartoon-forms.jpg">
<p>
You are logged in as <strong><% Sentosa::Users::get_userinfo($m->session->{auth_id}) || 'Guest' %></strong>.
</p>

<p>
Your groups are:
<ul>
% foreach my $group (Sentosa::Users::get_groupsuserinfo($m->session->{auth_id})) {
  <li><% $group->{groupname} %></li>
% }
</ul>

</p>
Your apps are:
<ul>
% foreach my $app (Sentosa::Users::get_appsuserinfo($m->session->{auth_id})) {
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
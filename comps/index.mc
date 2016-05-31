<%init>
  use Data::Dumper;

  $._title(Sentosa::Utils::get_sentosainfo);

  my $user = Sentosa::Users::get_userinfo($m->session->{auth_id});
  $._user($user);
</%init>

<h1>Welcome, <% $user->{userdesc} %></h1>
<p>
<img src="/static/images/home.jpg">
</p>

<p>
Your groups are:
<ul>
% foreach my $group (Sentosa::Users::get_groupsuserinfo($m->session->{auth_id})) {
  <li><% $group->{groupname} %></li>
% }
</ul>
</p>

<p>
Your apps are:
<ul>
% foreach my $app (Sentosa::Users::get_appsuserinfo($m->session->{auth_id})) {
  <li><% $app->{url} %></li>
% }
</ul>
</p>
% if ((!$user) || ($user->{id} == 0)) {
<p>
You are logged in as <strong>Guest</strong>. Please <a href="login">go to login page</a>!
</p>
% }
<hr>
<p>
<a href="https://github.com/fthiella/Sentosa">Sentosa Autoforms on GitHub</a>
</p>
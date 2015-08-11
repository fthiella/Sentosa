<%class>
</%class>

<h2>Welcome to <% Sentosa::Utils::get_appinfo %></h2>

<hr>

This is the empty default home page.

<a href="">Reload it!</a> or
<a href="?logout">Logout</a>
<%init>
  use Sentosa::Utils;
  $.title('Welcome to '.Sentosa::Utils::get_appinfo);
</%init>
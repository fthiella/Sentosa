<%class>
has 'title';
</%class>

<%augment wrap>
  <html>
    <head>
      <link rel="stylesheet" href="/static/css/style.css">
% $.Defer {{
      <title><% $.title %></title>
% }}
    </head>
    <body>
      <div>
        Logged in as user: <% $.authenticated_user || 'Guest' %>
      </div>
      <div>
        <form method="post">
        Username: <input type="text" name="username">
        Password: <input type="password" name="password">
        <input type="submit">
        </form>
      </div>
      <% inner() %>
    </body>
  </html>
</%augment>
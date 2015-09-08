<%class>
  has '_app';
</%class>
<%init>
  use Sentosa::Users;
  use Sentosa::Objects;
  # TODO: this should go to AJAX.

  my @sidebar;

  my @apps = map { {url => '/' . $_->{url} . '/', title => $_->{details}} } Sentosa::Users::get_appsuserinfo($m->session->{auth_id});
  my @queries = map { {url=> '/'. $._app . '/query/'.$_->{id}, title=>$_->{description}} } Sentosa::Objects::get_objectlist($m->session->{auth_id}, 'query', $._app);
  my @forms = map { {url=> '/' . $._app . '/form/'.$_->{id}, title=>$_->{description}} } Sentosa::Objects::get_objectlist($m->session->{auth_id}, 'form', $._app);

  if (!defined $._app) {
    # Applications
    push @sidebar, {type=>'fa-bar-chart-o', title=>'Applications', url=>'', second=> [
      map { {url => '/' . $_->{url} . '/', title => $_->{details}} } Sentosa::Users::get_appsuserinfo($m->session->{auth_id})
    ]}
  } else {
    push @sidebar, {type=>'fa-table', title=>'Queries', url=>'', second=>[ @queries ]};
    push @sidebar, {type=>'fa-edit', title=>'Forms', url=>'', second=>[ @forms ] };
    push @sidebar, {type=>'fa-dashboard', title=>'Dashboards', url=>''};
    push @sidebar, {type=>'fa-home', title=>'Home page', url=>'/'};
  }
</%init>
<& sidebar.mi, items=> \@sidebar &>
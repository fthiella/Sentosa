<%class>
  has '_app';
</%class>
<%init>
  use Sentosa::Users;
  use Sentosa::Objects;
  # TODO: this should go to AJAX.

  my @apps = map { {url => '/' . $_->{url} . '/', title => $_->{details}} } Sentosa::Users::get_appsuserinfo($m->session->{auth_id});
  my @queries = map { {url=> '/'. $._app . '/query/'.$_->{id}, title=>$_->{description}} } Sentosa::Objects::get_objectlist($m->session->{auth_id}, 'query', $._app);
  my @forms = map { {url=> '/' . $._app . '/form/'.$_->{id}, title=>$_->{description}} } Sentosa::Objects::get_objectlist($m->session->{auth_id}, 'form', $._app);
</%init>

            <& sidebar.mi, items=>
                [
                  {type=>'fa-bar-chart-o', title=>'Applications', url=>'', second=> [ @apps ] },
                  {type=>'fa-table', title=>'Queries', url=>'', second=>[ @queries ]},
                  {type=>'fa-edit', title=>'Forms', url=>'', second=>[ @forms ] },
                  {type=>'fa-dashboard', title=>'Dashboards', url=>''},
            
                ] &>
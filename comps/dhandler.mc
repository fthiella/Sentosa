<%class>
route "{_app:[a-z]+}/form/{_id:[0-9]+}", { _action=> 'form' };
route "{_app:[a-z]+}/db/{_id:[0-9]+}", { _action=> 'db' };
route "{_app:[a-z]+}/query/{_id:[0-9]+}", { _action=> 'query' };
route "{_app:[a-z]+}/query-data/{_id:[0-9]+}", { _action=> 'query-data' };
route "{_app:[a-z]+}/query-json/{_id:[0-9]+}/{_col:[a-zA-Z]+}", { _action=> 'query-json' };
route "{_app:[a-z]+}/download/{_id:[0-9]+}/{_name:[a-zA-Z.]*}", { _action=> 'download' }; # download with filename
route "{_app:[a-z]+}/download/{_id:[0-9]+}", { _action=> 'download' }; # no filename, redirect?
route "{_app:[a-z]+}/", { _action=> 'app' };
</%class>
<%init>
  my $appinfo = Sentosa::Users::get_appinfo($m->session->{auth_id}, $._app);
  $._title($appinfo->{details});
  $m->comp($._action.'.mi', %{$.args});
</%init>
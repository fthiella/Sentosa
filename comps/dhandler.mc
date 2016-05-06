<%class>
route "{_app:[^/]+}/form/{_id:[^/]+}", { _action=> 'form' };
route "{_app:[^/]+}/db/{_id:[^/]+}", { _action=> 'db' };
route "{_app:[^/]+}/query/{_id:[^/]+}", { _action=> 'query' };
route "{_app:[^/]+}/query-data/{_id:[^/]+}", { _action=> 'query-data' };
route "{_app:[^/]+}/query-json/{_id:[^/]+}/{_col:[^/]+}", { _action=> 'query-json' };
route "{_app:[^/]+}/download/{_id:[^/]+}/{_name:[^/]*}", { _action=> 'download' }; # download with filename
route "{_app:[^/]+}/download/{_id:[^/]+}", { _action=> 'download' }; # no filename, redirect?
route "{_app:[^/]+}/", { _action=> 'app' };
</%class>
<%init>
  my $appinfo = Sentosa::Users::get_appinfo($m->session->{auth_id}, $._app);
  $._title($appinfo->{details});
  $m->comp($._action.'.mi', %{$.args});
</%init>
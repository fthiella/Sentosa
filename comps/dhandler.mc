<%class>
route "{_app:[a-z]+}/form/{_id:[0-9]+}", { _action=> 'form' };
route "{_app:[a-z]+}/db/{_id:[0-9]+}", { _action=> 'db' };
route "{_app:[a-z]+}/query/{_id:[0-9]+}", { _action=> 'query' };
route "{_app:[a-z]+}/query-data/{_id:[0-9]+}", { _action=> 'query-data' };
route "{_app:[a-z]+}/", { _action=> 'app' };
</%class>
<%init>
  $.title($._app);
  $m->comp($._action.'.mi', %{$.args});
</%init>
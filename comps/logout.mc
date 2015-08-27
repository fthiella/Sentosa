<%init>
  delete $m->session->{auth_id};
  $m->redirect('/');
</%init>
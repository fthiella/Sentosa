use Sentosa::Users;

has '_username';
has '_password';
has 'logout';

method wrap() {

  if (defined $.logout) {
      $m->session->{auth_id} = undef;
      $m->req->{env}->{'psgix.session.options'}->{expires} = 0; # TODO: how to make it expire immediately?
      $m->redirect('/');
  };

  if ($._username || $._password) {
    my $auth_id = Sentosa::Users::auth_user( $._username, $._password );

    if (defined $auth_id) {
      $m->session->{auth_id} = $auth_id;
      $m->req->{env}->{'psgix.session.options'}->{expires} = "+1h";
    } else {
      $m->session->{auth_id} = undef;
      # $m->req->{env}->{'psgix.session.options'}->{expires} = 0;
    }
  }

  inner();
}

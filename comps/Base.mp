use Sentosa::Users;
use Sentosa::UserSessions;

has '_username';
has '_password';
has 'logout';
has 'authenticated_user';

method wrap() {

  if (defined $.logout) {
      $.authenticated_user(undef);
      $m->session->{auth_id} = undef;
      $m->redirect('/');
  };

  if ($._username || $._password) {
    $.authenticated_user( Sentosa::Users::auth_user( $._username, $._password ) );

    if (defined $.authenticated_user) {
      $m->session->{auth_id} = Sentosa::UserSessions::add_session($.authenticated_user);
    } else {
      $.authenticated_user(undef);
      $m->session->{auth_id} = undef;
    }
  }
 
  $.authenticated_user(Sentosa::UserSessions::session_is_valid($m->session->{auth_id}));
 
  inner();
}

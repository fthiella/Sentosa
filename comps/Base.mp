use Sentosa::Users;
use Sentosa::UserSessions;

has 'username';
has 'password';
has 'authenticated_user';

method wrap() {
  if ($.username || $.password) {
    $.authenticated_user( Sentosa::Users::auth_user( $.username, $.password ) );

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

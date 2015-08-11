package Sentosa::UserSessions;
use Poet::Moose;
extends 'Poet::Import';
 
use Poet qw($dbh);
 
sub session_is_valid {
  my ( $sid ) = @_;
  
  if (defined $sid) {
    my $ar = $dbh->selectall_arrayref(
      "SELECT id, auth_user_id
       FROM af_sessions
       WHERE id=? AND auth_ts>=datetime('now', '-30 minute')",
      {Slice => {}},
      $sid
    );
    
    if ($ar->[0]->{id} eq $sid) {
      # TO DO: Big Warning - this is UNSAFE - need to perform some extra checks!
      return $ar->[0]->{auth_user_id};
    }
  }
 return undef;
}
 
sub add_session {
  my ($nid) = @_;
  my $sth = $dbh->prepare('INSERT INTO af_sessions (auth_user_id) VALUES (?)');
  $sth->execute($nid);
  return $dbh->last_insert_id('', '', 'af_sessions', 'id');
}
 
1;

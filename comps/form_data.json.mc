<%flags>
  extends => 'Base.mp';
</%flags>
<%class>
  has 'id';
</%class>
<%init>
  use JSON;
  use Data::Dumper;
  use Sentosa::Objects;
  
  my %h = ();

  foreach my $col (Sentosa::Objects::get_formcolumns($.id, $.authenticated_user)) {
    push @{$h{ $col->{id_object} }}, $col->{col};
  }
</%init>
<%perl>
  $m->send_json( \%h );
</%perl>

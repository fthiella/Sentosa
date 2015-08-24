<%doc>
Creates a hash that defines the form, then calls form.mi

Example:

{
  id => 1,
  description => 'Users Form',
  boxes => [
    {
      name => 'box1', elements => [
        {caption => 'id', col => 'id', type => 'hidden'}
      ]
    },
    {
      name => 'box2', elements => [
        {caption => 'User Name', col => 'username', type => 'text'},
        {caption => 'Password', col => 'password', type => 'text'}
      ],
    }
  ],
}
</%doc>
<%class>
  has '_id';
	has '_record' => (default => '');
</%class>
<%init>
  use Sentosa::Objects;
  my ($form) = Sentosa::Objects::get_object($._id, 'form', $m->session->{auth_id});
  if (!$form) { $m->not_found(); }; # form not found
  
  my @boxes;

  foreach my $box (Sentosa::Objects::get_formboxes($form->{id}, $m->session->{auth_id})) {
    my @box_elements;
    foreach my $element (Sentosa::Objects::get_formelements($form->{id}, $box->{box}, $m->session->{auth_id})) {
      push @box_elements, {caption=>$element->{caption}, col=>$element->{col}, type=>$element->{type}, params=>$element->{params}};
    }
    push @boxes, {name=>$box->{box}, elements=>\@box_elements};
  }
</%init>
<& form.mi, form=>{id=>$form->{id}, description=>$form->{description}, boxes=>\@boxes} &>
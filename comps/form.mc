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
  use JSON ();
  use Sentosa::Objects;

  my ($form) = Sentosa::Objects::get_object($._id, 'form', $m->session->{auth_id});
  if (!$form) { $m->not_found(); }; # form not found
  
  my @boxes = JSON->new->utf8->decode($form->{def});
</%init>
<&
  form.mi,
    form => {
      id => $form->{id},
      description => $form->{description},
      record => $._record,
	  pk => $form->{pk},
      boxes => @boxes
    }
&>
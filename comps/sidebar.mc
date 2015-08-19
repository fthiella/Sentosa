<%class>
has 'authenticated_user';
</%class>
<%init>
  use Sentosa::Users;
  use Sentosa::Objects;
  # TODO: this should go to AJAX.
  # TODO: And maybe use some perlish function instead of foreach? ;)
  my @apps = map { {url => $_->{url} . '/', title => $_->{details}} } Sentosa::Users::get_appsuserinfo($.authenticated_user);
  my @queries = map { {url=>'query?_id='.$_->{id}, title=>$_->{description}} } Sentosa::Objects::get_objectsdetails($.authenticated_user, 'query');
  my @forms = map { {url=>'form?_id='.$_->{id}, title=>$_->{description}} } Sentosa::Objects::get_objectsdetails($.authenticated_user, 'form');
</%init>
            
            <& sidebar.mi, items=>
                [
                  {type=>'fa-bar-chart-o', title=>'Applications', url=>'', second=> [ @apps ] },
                  {type=>'fa-table', title=>'Queries', url=>'', second=>[ @queries ]},
                  {type=>'fa-edit', title=>'Forms', url=>'', second=>[ @forms ] },
                  {type=>'fa-dashboard', title=>'Dashboards', url=>''},
            
                ] &>
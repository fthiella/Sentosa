<%class>
  has 'username';
  has 'password';
</%class>
        <div class="row">
            <div class="col-md-4 col-md-offset-4">
                <div class="login-panel panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title">Please Sign In</h3>
                    </div>
                    <div class="panel-body">
                        <form role="form" action="" method="post">
                            <fieldset>
                                <div class="form-group">
                                    <input class="form-control" placeholder="Username" name="username" type="username" autofocus>
                                </div>
                                <div class="form-group">
                                    <input class="form-control" placeholder="Password" name="password" type="password" value="">
                                </div>
                                <div class="checkbox">
                                    <label>
                                        <input name="remember" type="checkbox" value="Remember Me">Remember Me
                                    </label>
                                </div>
                                <input class="btn btn-lg btn-success btn-block" type="submit">Login
                            </fieldset>
                        </form>
                    </div>
                </div>
            </div>
        </div>
<%init>
  use Sentosa::Utils;
  
  # logout
  delete $m->session->{auth_id};

  if ($.username || $.password) {
    my $auth_id = Sentosa::Users::auth_user( $.username, $.password );

    if (defined $auth_id) {
      $m->req->{env}->{'psgix.session.options'}->{change_id} = 1;
      $m->session->{auth_id} = $auth_id;
      $m->redirect('/'); # login succesful
      return;
    }
  }

  $.title(Sentosa::Utils::get_appinfo);
</%init>
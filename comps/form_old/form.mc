<%class>
  has 'id';
	has 'record' => (default => '');
</%class>
<%init>
  use feature qw( switch );
</%init>
<%flags>
#  extends => '../Base.mp';
</%flags>
% # ---------- INPUT ELEMENTS ----------


<%method input_hidden ($id, $caption)>    <label for="<% $id | HTMLEntities %>" class="control-label col-sm-2"><% $caption | HTMLEntities %> (hidden)</label>
    <div class="col-sm-10">
      <input type="text" id="<% $id %>" name="<% $id %>" value="" class="form-control" readonly>
    </div>
</%method>


<%method input_text ($id, $caption, $value)>    <label for="<% $id %>" class="control-label col-sm-2"><% $caption | HTMLEntities %></label>
    <div class="col-sm-10">
      <input type="text" id="<% $id %>" name="<% $id %>" value="<% $value %>" class="form-control">
    </div>
</%method>


<%method input_checkbox ($id, $caption, $value)>    <div class="checkbox">
	<label>
    <input type="checkbox" id="<% $id %>" name="<% $id %>" value="<% $value %>">
    <% $caption %>
	</label>
</div>
</%method>


<%method input_file ($id, $caption)><p><% $caption %>:</p>
<p><input type="file" id="<% $id %>" name="<% $id %>" /></p>

<div id="<% $id %>_progress">
<div id="<% $id %>_bar"></div><div id="<% $id %>_percent">0%</div>
</%method>


<%method query ($id, $hide_title, $hide_top, $hide_bottom) >
<& query.mc, id => $id, hide_title => $hide_title, hide_top => $hide_top, hide_bottom => $hide_bottom &>
</%method>


<%method input_actions ($id, $message)>
  <div id="<% $id %>_message"><% $message | HTMLEntities %></div>
</%method>


<%method input_message ($id)>
  <div class="form-actions">
    <button type="button" id="save" value="save" class="btn">Save</button>
    <button type="button" id="gotofirst" value="primo" class="btn">First</button>
    <button type="button" id="indietro" value="indietro" class="btn">Back</button>
    <button type="button" id="avanti" value="avanti" class="btn">Forward</button>
    <button type="button" id="ultimo" value="ultimo" class="btn">Last</button>
    <button type="button" id="insert" value="insert" class="btn">New</button>
  </div>
</%method>


% # ------------------------------------
% my $sth = $samdb->prepare('SELECT id, description FROM am_objects WHERE objectType=? AND objectName=?');
% $sth->execute('Form', $.id);
% my $obj = $sth->fetchrow_hashref() || die("Form not found!");
% $sth->finish();

<script src="form.js"></script>

<div class="row">
					<div class="col-sm-12">
						<div class="box box-bordered box-color">
							<div class="box-title">
								<h3>
									<i class="fa fa-th-list"></i><% $$obj{description} | HTMLEntities %>
                </h3>
							</div>
							<div class="box-content nopadding">

<form id="<% $.id %>" action="db/<% $.id %>" method="post" enctype="multipart/form-data" class='form-horizontal form-bordered'>

  <input type="hidden" id="is_dirty" name="is_dirty" value="0" />
  <input type="hidden" id="goto_record" name="goto_record" value="<% $.record %>" />
<%perl>
  my $sth_box = $samdb->prepare("SELECT DISTINCT box FROM am_forms WHERE objectid=?");
  $sth_box->execute($$obj{id});

  while (my $box = $sth_box->fetchrow_array()) {
</%perl>
<div id=<% $.id %>_<% $box %>" class="form-group">
<%perl>
    my $sth_itm = $samdb->prepare("SELECT sourcecolumn, type, name, caption FROM am_forms WHERE objectid=? AND box=?");
    $sth_itm->execute($$obj{id}, $box);

    while (my ($sourcecolumn, $type, $name, $caption) = $sth_itm->fetchrow_array()) {
			given ($type) {
				when ('hidden')   { print $.input_hidden($name, $caption); }
        when ('text')     { print $.input_text($name, $caption, ''); }
        when ('checkbox') { print $.input_checkbox($name, $caption, ''); }
        when ('file')			{ print $.input_file($name, $caption, ''); }
				when ('query')    { print $.query($name, '1', '1', '1'); }
			}
   }
		
	 $sth_itm->finish();
   print '</div>';
  }
  $sth_box->finish();
	
	print $.input_message($.id, '');

	print $.input_actions($.id);
</%perl>
</form>

              </div>
						</div>
					</div>
				</div>
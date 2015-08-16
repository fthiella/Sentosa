<%class>
  has 'id';
	has 'record' => (default => '');
</%class>
<%init>
  use Sentosa::Objects;
  use Data::Dumper;
  use feature qw( switch );
</%init>
<%flags>
#  extends => '../Base.mp';
</%flags>
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


% my $form = Sentosa::Objects::get_object($.id, 'form', $.authenticated_user); # TODO: dereference hash...?
<script src="/static/js/forms.js"></script>

<div class="row">
					<div class="col-sm-12">
						<div class="box box-bordered box-color">
							<div class="box-title">
								<h3>
									<i class="fa fa-th-list"></i><% @{$form}[0]->{description} | HTMLEntities %>
                </h3>
							</div>
							<div class="box-content nopadding">

% # TODO: use Poet function to create URL?
<form id="<% @{$form}[0]->{id} %>" action="db?id=<% @{$form}[0]->{id} %>" method="post" enctype="multipart/form-data" class='form-horizontal form-bordered'>

  <input type="hidden" id="is_dirty" name="<% @{$form}[0]->{id} %>_is_dirty" value="0" />
  <input type="hidden" id="goto_record" name="goto_record" value="<% $.record %>" />

% # TODO: is order of boxes guaranteed?
% foreach my $box (Sentosa::Objects::get_formboxes(@{$form}[0]->{id}, $.authenticated_user)) {  
<div id=<% @{$form}[0]->{id} %>_<% $box->{box} %>" class="form-group">

<%perl>
    foreach my $element (Sentosa::Objects::get_formelements(@{$form}[0]->{id}, $box->{box}, $.authenticated_user)) {
			given ($element->{type}) {
				when ('hidden')   { print $.input_hidden($element->{col}, $element->{caption}); }
        when ('text')     { print $.input_text($element->{col}, $element->{caption}, ''); }
        when ('checkbox') { print $.input_checkbox($element->{col}, $element->{caption}, ''); }
        when ('file')			{ print $.input_file($element->{col}, $element->{caption}, ''); }
				when ('query')    { print $.query($element->{col}, $element->{caption}, '1', '1', '1'); }
			}
    }
</%perl>

</div>
% }
<% $.input_message(@{$form}[0]->{id}, '') %>
<% $.input_actions(@{$form}[0]->{id}) %>

</form>

              </div>
						</div>
					</div>
</div>
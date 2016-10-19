/**
 * Created by dmytro on 10/7/16.
 */

// this function return search results and using for sort them
// url receive route to action, params receive data for searching and sorting data
// params prepare in views
function classifier_search(url, params) {
  $('#spinner-container').show();
  $.ajax({
    type: 'get',
    url: url,
    async: false,
    dataType: 'script',
    data: params,
    complete: function() {
      share_buttons_set_url(this.url);
    }
  });
  $('#spinner-container').hide();
}

function init_items_select2_with_field_id(field_id, parent_field_id, url, placeholder){
  $(field_id).select2({
//    sortResults: function(results, container, query) {
//      if (query.term) {
//        // use the built in javascript sort function
//        return results.sort(function(a, b) {
//          if (a.text.length > b.text.length) {
//            return 1;
//          } else if (a.text.length < b.text.length) {
//            return -1;
//          } else {
//            return 0;
//          }
//        });
//      }
//      return results;
//    },
    allowClear: true,
    multiSelect: false,
    multiple: false,
    placeholder: placeholder,
    minimumInputLength: 2,
    width: '100%',
    ajax: {
      url: url,
      dataType: 'json',
      quietMillis: 250,
      data: function (term, page) {
        return {
          type: $(parent_field_id).val(),
          role: $(field_id).data('role'),
          region: $('[name="[apply_region]"]:checked').val(),
          query: term // search term
        };
      },
      results: function (data, page) {
        var resArr = [];
        for(var i = 0; i < data.length; i++) {
          var arr = {};
          arr['id'] = data[i].id;
          arr['text'] = data[i].text;
          resArr.push(arr);
        }
        return { results: resArr };
      },
      cache: true
    },
    formatResult: function(element){
      return element.text + ' (' + element.id + ')';
    }
  });
}

// this function return items by type and using for sort them
// function change items list and items select options depend on type value
// sorting params may be empty
// sorting apply for items list only (manage by controller)
function get_items(url, type, role, _sort_param) {
  $('#spinner-container').show();
  var town_id = $('#_item_type_payers').data('town-id');
  $.ajax({
    type: 'get',
    url: url,
    async: false,
    dataType: 'script',
    data: {
      town_id: town_id,
      type: type,
      role: role,
      region: $('[name="[apply_region]"]:checked').val(),
      sort_column: (_sort_param != null ? _sort_param.sort_col : null),
      sort_direction: (_sort_param != null ? _sort_param.sort_dir : null)
    }
  });
  $('#spinner-container').hide();
}

// TODO: refactor in future
function share_buttons_set_url(url) {
    if (!$('.demo_index')) {
        addthis.update('share', 'url', url.replace('search_e_data', 'direct_link'));
        console.log(url.replace('search_e_data', 'direct_link'));
    }
}

// switch sort direction
function sort_direction(attr) {
  if (attr == 'asc') {
    return 'desc';
  }
  else {
    return 'asc';
  }
}

// add breadcrumbs element and create event-listener for handheld remove it
function addBreadcrumbs(title, url) {
  var breadcrumbs_list = $('.breadcrumb');
  var parent_el = breadcrumbs_list.find('li.active');
  parent_el.children().attr('href', url).attr('data-remote', "true");
  parent_el.removeClass('active');
  var active_li = $('<li></li>').addClass('active');
  var a_value = $('<a>').html(title);
  active_li.append(a_value);
  breadcrumbs_list.append(active_li);
  // Handheld action 'back'
  parent_el.children().click(function() {
    // remove previous <li>
    parent_el.next().remove();
    parent_el.addClass('active');
  });
}
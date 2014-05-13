function updateFirstPage(){
    //temporary put this function here, need to find better place or rename the updateFirstPage
    renameHFMissingField();
    var items = $j('div[itemid]');
    var item_type = getItemType(items);
    var item_ids = getItemIds(items);

    if (item_type != null && item_ids.length > 0){
        $j('.exhibit-collectionView-body').html(' ');
        $j.ajax({
            url: faceted_items_url,
            async: false,
            data: {item_ids: item_ids, item_type: item_type}
        })
            .done(function( data ) {
                updateContent(data.resource_list_items);

                $j('.exhibit-viewPanel').removeClass('exhibit-ui-protection');
                $j('.exhibit-collectionView-header-groupControl').hide();
                $j('.exhibit-toolboxWidget-button').hide();
                decodeValueTooltip();

                $j('.exhibit-viewPanel-viewContainer').show();
            });
    }
}

jQuery.noConflict();
var $j = jQuery;
$j(document).ready(function(){
    $j(document).on("exhibitConfigured.exhibit", function() {
        defaultSearchText();
    });

    $j(document).on("onItemsChanged.exhibit", function() {
        updateFirstPage();
    });

    $j(document).bind("registerLocales.exhibit", function() {
        $j(document).trigger("beforeLocalesRegistered.exhibit");
        new Exhibit.Locale("default", "<%= asset_path('exhibit/locales/en/locale.js') %>");
        new Exhibit.Locale("en", "<%= asset_path('exhibit/locales/en/locale.js') %>");
        $j(document).trigger("localesRegistered.exhibit");
    });
});

function defaultSearchText(){
    var default_text = 'Search filters below';
    $j('div[id="facet_search_box"] input').each(function(){
        $j(this).attr('placeholder',default_text);
    });
}

function getItemIds(items){
    var item_ids = items.map(function(){
        var exhibit_item_id = $j(this).attr("itemid");
        return database.getObject(exhibit_item_id, 'item_id');
    }).get();

    return item_ids;
}

function getItemType(items){
    return database.getObject(items.attr("itemid"), 'type');
}

function updateContent(resource_list_items){
    var collection_view_body = $j('.exhibit-collectionView-body');
    collection_view_body.html(resource_list_items);
}

function decodeValueTooltip(){
    $j('.exhibit-facet-value').map(function(){
        var title = $j(this).attr("title");
        $j(this).attr("title", decodeHTML(title));
    })
}

//rename Hierachical Facet Missing Field of the root level: from others to missing this field
function renameHFMissingField(){
    var missing_field_elements = $j('.exhibit-flowingFacet-body').children("[title='(others)']");
    var replaced_term = "(missing this field)";
    missing_field_elements.map(function(){
        $j(this).attr("title", replaced_term);
        var value_link = $j(this).children('.exhibit-flowingFacet-value-link');
        value_link.html("<span class='exhibit-facet-value-missingThisField'>(missing this field)</span>");
    })
}
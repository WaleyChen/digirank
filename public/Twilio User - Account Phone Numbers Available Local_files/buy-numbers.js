if (typeof twilio == "undefined") {
    var twilio = {};
}
twilio.realm = "prod";
$(function () {
    if ($('#shortcodes-panel').length == 0) {
        return;
    }
    $('#iso-select').change(function () {
        window.location.href = '/user/account/phone-numbers/available/' + $(this).val() + '/shortcodes';
    });
    $('#user-iso-select').bind('iso-changed', function (event, data) {
        $('#iso-select').selectBox('value', data.value);
        $('#iso-select').trigger('change');
    });
});;
$(function () {
    if ($('#tollfree-numbers-panel').length === 0) {
        return;
    }
    var prefix = 'Any';
    if ($('#international-prefix').length) {
        prefix = $('#international-prefix').val();
    }
    var iso = $('#iso-select').val();
    var geocoder = null;
    var currentRow = null;
    var currentPage = 0;
    $('#preview-purchase').jqm();
    $('#confirm-purchase').jqm();
    $('#add-certification').jqm();
    $('#iso-select').change(function () {
        window.location.href = '/user/account/phone-numbers/available/' + this.value + '/toll-free';
    });
    $('#user-iso-select').bind('iso-changed', function (event, data) {
        $('#iso-select').selectBox('value', data.value);
        $('#iso-select').trigger('change');
    });
    $('#current-tollfree-search-type').click(function (e) {
        e.preventDefault();
        $(this).addClass('dropdown');
        $('#tollfree-search-type-list').show();
    });
    $('#tollfree-search-type-list a').click(function (e) {
        e.preventDefault();
        prefix = $(this).attr('rel');
        $('#tollfree-search-type-list li').removeClass('selected');
        $(this).closest('li').addClass('selected');
        $('#tollfree-search-type-list').hide();
        $('#tollfree-search-type .type-label').text(prefix);
    });
    $('#tollfree-search-button').click(function (e) {
        e.preventDefault();
        currentPage = 0;
        performSearch();
    });
    $('#tollfree-keywords').keyup(function (e) {
        if (e.keyCode == 13) {
            $('#tollfree-search-button').trigger('click');
        }
    });
    $('a.buy-number').live('click', function (e) {
        e.preventDefault();
        var info = $.parseJSON($(this).attr('rel'));
        twilio.numbers.currentRow = $(this).closest('tr');
        twilio.numbers.showBuyDialog(info);
    });
    $('#buy-this-number').click(function (e) {
        e.preventDefault();
        twilio.numbers.buyNumber(twilio.numbers.numberInfo.id);
    });
    $('#more-results-button').live('click', function (e) {
        e.preventDefault();
        currentPage++;
        $('#more-results-spinner').show();
        performSearch();
    });

    function performSearch() {
        $('#search-submit-spinner').show();
        var term = $('#tollfree-keywords').val();
        prefix = $.trim(prefix);
        term = $.trim(term);
        $('#search-terms').html('');
        if (prefix.length) {
            $('#search-terms').append($('<span class="keyword-text"></span>').text(prefix));
        }
        if (prefix.length && term.length) {
            $('#search-terms').append(' and ');
        }
        if (term.length) {
            $('#search-terms').append($('<span class="keyword-text"></span>').text(term));
        }
        $.get('/user/account/phone-numbers/available/' + iso + '/toll-free/search', {
                'prefix': prefix,
                'searchTerm': $('#tollfree-keywords').val(),
                'page': currentPage
            }, null, 'html').success(function (result) {
                $('#search-results-target').html(result);
            }).error(function (result) {
                $('#search-results-target').html(result.responseText);
            }).always(function () {
                $('#search-submit-spinner').hide();
                $('#pre-search-results').hide();
                $('#search-results').show();
            });
    }
    if ($("#reserved-did").length > 0) {
        var info = $.parseJSON($("#reserved-did").attr("value"));
        twilio.numbers.showBuyDialog(info);
    }
});;
$(function () {
    if ($('#local-numbers-panel').length === 0) {
        return;
    }
    twilio.analytics.event('/user/account/phone-numbers/available/local');
    var iso = $('#iso-select').val();
    var country = $.trim($('#iso-select option:selected').text());
    var geocoder = null;
    var currentPage = 0;
    var mode = 'numeric';
    $('#preview-purchase').jqm();
    $('#confirm-purchase').jqm();
    $('#add-certification').jqm();
    $('#add-certification-confirmation').jqm();
    $('#iso-select').change(function () {
        window.location.href = '/user/account/phone-numbers/available/' + this.value + '/local';
    });
    $('#user-iso-select').bind('iso-changed', function (event, data) {
        $('#iso-select').selectBox('value', data.value);
        $('#iso-select').trigger('change');
    });
    $('#current-search-type').click(function (e) {
        e.preventDefault();
        $(this).addClass('dropdown');
        $('#search-type-list').show();
    });
    $('#number-search-type, .search-by-number').click(function (e) {
        e.preventDefault();
        mode = 'numeric';
        $('#search-type-list').hide();
        $('#current-search-type').removeClass('dropdown');
        $('#current-search-type span').removeClass('location-icon').addClass('number-icon');
        $('#location-input-type').hide();
        $('#number-input-type').show();
        $('#location-input-instruct').hide();
        $('#number-input-instruct').show();
        $('#pre-local-location').hide();
        $('#pre-local-number').show();
    });
    $('#location-search-type, .search-by-location').click(function (e) {
        e.preventDefault();
        mode = 'location';
        $('#search-type-list').hide();
        $('#current-search-type').removeClass('dropdown');
        $('#current-search-type span').removeClass('number-icon').addClass('location-icon');
        $('#number-input-type').hide();
        $('#location-input-type').show();
        $('#number-input-instruct').hide();
        $('#location-input-instruct').show();
        $('#pre-local-number').hide();
        $('#pre-local-location').show();
    });
    $('#search-button').click(function () {
        currentPage = 0;
        performSearch();
    });
    $('#area-code-keywords, #subscriber-keywords, #location-keywords').keyup(function (event) {
        if (event.keyCode == 13) {
            $('#search-button').trigger('click');
        }
    });
    $('a.buy-number').live('click', function (e) {
        e.preventDefault();
        var info = $.parseJSON($(this).attr('rel'));
        currentRow = $(this).closest('tr');
        twilio.numbers.showBuyDialog(info);
    });
    $('#buy-this-number').click(function (e) {
        e.preventDefault();
        twilio.numbers.buyNumber(twilio.numbers.numberInfo.id);
    });
    $('#more-results-button').live('click', function (e) {
        e.preventDefault();
        currentPage++;
        $('#more-results-spinner').show();
        performSearch();
    });
    $('#certify').click(function (e) {
        e.preventDefault();
        if (!$('#certify').hasClass('disabled')) {
            twilio.numbers.addCertification(twilio.numbers.numberInfo);
        }
    });
    $('#confirm-certification').click(function () {
        $('#certify').toggleClass('disabled');
        $('#certify').toggleClass('basic-link-button');
        $('#certify').toggleClass('action-link-button');
    });
    $('#terms-control').click(function (e) {
        e.preventDefault();
        $('#terms').slideToggle();
    });
    $('a.national-number-search').click(function () {
        var nationalNumberPrefix = $.trim($(this).attr('rel'));
        $('#subscriber-keywords').val(nationalNumberPrefix);
        $('#add-certification').jqmHide();
        performSearch();
    });

    function performSearch() {
        if (mode == 'numeric') {
            numericSearch();
        } else {
            locationSearch();
        }
    }

    function numericSearch() {
        $('#search-submit-spinner').show();
        var prefix = $('#area-code-keywords').val();
        var term = $('#subscriber-keywords').val();
        prefix = $.trim(prefix);
        term = $.trim(term);
        $('#search-terms').html('');
        if (prefix.length) {
            $('#search-terms').append($('<span class="keyword-text"></span>').text(prefix));
        }
        if (prefix.length && term.length) {
            $('#search-terms').append(' and ');
        }
        if (term.length) {
            $('#search-terms').append($('<span class="keyword-text"></span>').text(term));
        }
        $('#search-terms').append(' in ');
        $('#search-terms').append($('<span class="keyword-text"></span>').text(country));
        $.get('/user/account/phone-numbers/available/' + iso + '/local/search', {
                'prefix': prefix,
                'searchTerm': term,
                'mode': 'numeric',
                'page': currentPage
            }, null, 'html').success(function (result) {
                $('#search-results-target').html(result);
                $('.cert-tooltip').tooltip();
            }).error(function (result) {
                $('#search-results-target').html(result.responseText);
            }).always(function () {
                $('#search-submit-spinner').hide();
                $('#pre-search-results').hide();
                $('#search-results').show();
            });
    }

    function locationSearch() {
        if (!geocoder) {
            geocoder = new google.maps.Geocoder();
        }
        $('#search-submit-spinner').show();
        var location = $('#location-keywords').val();
        location = $.trim(location);
        geocoder.geocode({
                "address": location
            }, function (results, status) {
                var options = {
                    'mode': 'region',
                    'page': currentPage
                };
                if (status == google.maps.GeocoderStatus.OK && results.length > 0) {
                    location = results[0].formatted_address;
                    var index = $.inArray("administrative_area_level_1", results[0].types);
                    if (index >= 0) {
                        options.region = results[0].address_components[index].short_name;
                    } else {
                        options.mode = 'latlong';
                        options.latitude = results[0].geometry.location.lat();
                        options.longitude = results[0].geometry.location.lng();
                    }
                } else {
                    options.region = location;
                }
                $('#search-terms').html('');
                $('#search-terms').append($('<span class="keyword-text"></span>').text(location));
                $.get('/user/account/phone-numbers/available/' + iso + '/local/search', options, null, 'html').success(function (result) {
                    $('#search-results-target').html(result);
                    $('.cert-tooltip').tooltip();
                }).error(function (result) {
                    $('#search-results-target').html(result.responseText);
                }).always(function () {
                    $('#search-submit-spinner').hide();
                    $('#pre-search-results').hide();
                    $('#search-results').show();
                });
            });
    }
    if ($("#reserved-did").length > 0) {
        var info = $.parseJSON($("#reserved-did").attr("value"));
        twilio.numbers.showBuyDialog(info);
    }
});;
twilio.numbers = {
    numberInfo: null,
    canPurchase: true,
    currentRow: false,
    reserveDid: function (info) {
        var url = '/user/account/phone-numbers/available/' + info.id;
        var data = {
            "csrfToken": $("input[name=csrfToken]").attr("value")
        };
        $.post(url, data, null, 'json').error(function (result) {



            twilio.numbers.numberInfo.isCertified = true;
            $('#add-certification').jqmHide();
            $('#confirm-certification').trigger('click');
            twilio.numbers.showBuyDialog(twilio.numbers.numberInfo);



        });
    },
    buyNumber: function (sid) {
        if (!twilio.numbers.canPurchase) {
            return;
        }
        twilio.numbers.canPurchase = false;
        $("#preview-purchase .spinner").show();
        var url = "/user/account/phone-numbers/available/" + sid;
        var data = {
            "status": "purchased",
            "csrfToken": $('input[name=csrfToken]').val()
        };

        $.post(url, data, null, 'json').success(function (result) {

            twilio.numbers.showConfirmDialog(result);

        }).error(function (result) {

            twilio.numbers.showConfirmDialog(result);
            
            // $('#preview-purchase .spinner').hide();
            // var errorText = "Sorry, this number is no longer available";
            // try {
            //     var message = $.parseJSON(result.responseText);
            //     errorText = message.error || errorText;
            // } catch (err) {}
            // $('#preview-purchase .error').text(errorText).show();
        }).always(function () {
            twilio.numbers.canPurchase = true;
        });
    },

    addCertification: function (info) {
        $('#add-certification-confirmation .spinner').show();
        var url = '/user/account/settings/international/certifications';
        var data = {
            "phoneNumber": info.number
        };
        $.post(url, data, null, 'json').success(function (result) {


            twilio.numbers.numberInfo.isCertified = true;
            $('#add-certification').jqmHide();
            $('#confirm-certification').trigger('click');
            twilio.numbers.showBuyDialog(twilio.numbers.numberInfo);


        }).error(function (result) {
            $('#add-certification .spinner').hide();
            var errorText = "Sorry, this number is no longer available";
            try {
                var message = $.parseJSON(result.responseText);
                errorText = message.error || errorText;
            } catch (err) {}
            $('#add-certification .error').text(errorText).show();
        }).always(function () {
            $('#add-certification-confirmation').show();
        });
    },
    showCertificationDialog: function (info) {
        $("#upgrade-account").attr("href", function (i, val) {
            return val + "?g=" + encodeURIComponent(window.location.pathname + '?sid=' + info.id);
        });
        $('#add-certification .error').hide();
        $('#add-certification .spinner').hide();
        if (info.warning) {
            $('#add-certification .warning').text(info.warning).show();
        } else {
            $('#add-certification .warning').hide();
        }
        if (info.sms) {
            $('#add-certification #sms-feature-supported').show();
            $('#add-certification #sms-feature-unsupported').hide();
        } else {
            $('#add-certification #sms-feature-unsupported').show();
            $('#add-certification #sms-feature-supported').hide();
        }
        if (info.voice) {
            $('#add-certification #voice-feature-supported').show();
            $('#add-certification #voice-feature-unsupported').hide();
        } else {
            $('#add-certification #voice-feature-unsupported').show();
            $('#add-certification #voice-feature-supported').hide();
        }
        $('p.certification').hide();
        $('p.certification.' + info.certificationType).show();
        $('#upgrade-notice').show();
        $('#certification-notice').show();
        $('#add-certification-amount').text(info.price);
        $('#add-certification').jqmShow();
    },
    showBuyDialog: function (info) {
        this.reserveDid(info);
        twilio.numbers.numberInfo = info;
        if (twilio.numbers.numberInfo.requiresCertification && !twilio.numbers.numberInfo.isCertified) {
            return this.showCertificationDialog(info);
        }
        $('#preview-purchase .dialog-heading').text(info.displayPhoneNumber);
        $("#upgrade-account").attr("href", function (i, val) {
            return val + "?g=" + encodeURIComponent(window.location.pathname + '?sid=' + info.id);
        });
        $('#preview-purchase .error').hide();
        $('#preview-purchase .spinner').hide();
        if (info.requiresCertification) {
            $('#certification-reminder').show();
        } else {
            $('#certification-reminder').hide();
        }
        if (info.warning) {
            $('#preview-purchase .warning').text(info.warning).show();
        } else {
            $('#preview-purchase .warning').hide();
        }
        if (info.sms) {
            $('#preview-purchase #sms-feature-supported').show();
            $('#preview-purchase #sms-feature-unsupported').hide();
        } else {
            $('#preview-purchase #sms-feature-unsupported').show();
            $('#preview-purchase #sms-feature-supported').hide();
        }
        if (info.voice) {
            $('#preview-purchase #voice-feature-supported').show();
            $('#preview-purchase #voice-feature-unsupported').hide();
        } else {
            $('#preview-purchase #voice-feature-unsupported').show();
            $('#preview-purchase #voice-feature-supported').hide();
        }
        $('.dialog-button-container, .number-preview-details', '#preview-purchase').show();
        $('#upgrade-notice').show();
        $('#preview-purchase-amount').text(info.price);
        $('#preview-purchase').jqmShow();
    },
    showConfirmDialog: function (result) {
        $('#preview-purchase').jqmHide();
        $('#add-certification-confirmation').jqmHide();
        if (twilio.numbers.currentRow) {
            twilio.numbers.currentRow.fadeOut();
            twilio.numbers.currentRow = null;
        }
        $('#confirm-purchase .phone-number').text(twilio.numbers.numberInfo.displayPhoneNumber);
        $('#setup-this-number').attr('href', '/user/account/phone-numbers/' + result.sid);
        $('#confirm-purchase').jqmShow();
    }
};